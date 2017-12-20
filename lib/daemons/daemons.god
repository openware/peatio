RAILS_ENV  = ENV.fetch('RAILS_ENV', 'development')
RAILS_ROOT = File.expand_path('../../..', __FILE__)

# Create non-default log/daemons directory.
require 'fileutils'
FileUtils.mkdir_p "#{RAILS_ROOT}/log/daemons"

def daemon(name, options = {})
  God.watch do |w|
    command        = "bundle exec ruby lib/daemons/#{options.fetch(:script)}"
    command       += ' ' + options[:arguments].join(' ') if options.key?(:arguments)
    filesafe_name  = name.gsub(/\W/, '_')

    w.name  = name
    w.start = command
    w.log   = "#{RAILS_ROOT}/log/daemons/#{filesafe_name}.log"
    w.dir   = RAILS_ROOT
    w.env   = { 'RAILS_ENV' => RAILS_ENV, 'RAILS_ROOT' => RAILS_ROOT }

    # Peatio has lot of dependencies which take some time to load ever on fast disks.
    # God, by default, doesn't wait before resuming normal monitoring operations.
    # So we need to adjust this variable so God will wait 10 seconds on start/restart operations.
    w.grace = 10.seconds

    # God will send SIGTERM to the process and wait 10 seconds.
    # If process has still not exited it will be killed by sending SIGKILL.
    w.stop_signal  = 'TERM'
    w.stop_timeout = 10.seconds

    # God will restart process if it's memory usage exceeds 64 megabytes.
    w.keepalive memory_max: 64.megabytes

    # Allow customizations.
    yield(w) if block_given?
  end
end

daemon 'amqp:deposit_coin',
       script:   'amqp_daemon.rb',
       arguments: %w[ deposit_coin deposit_coin_address ]

daemon 'amqp:market_data',
       script:   'amqp_daemon.rb',
       arguments: %w[ slave_book market_ticker ]

daemon 'amqp:matching',
       script:   'amqp_daemon.rb',
       arguments: %w[ matching ]

daemon 'amqp:notification',
       script:   'amqp_daemon.rb',
       arguments: %w[ email_notification ]

daemon 'amqp:order_processor',
       script:   'amqp_daemon.rb',
       arguments: %w[ order_processor ]

daemon 'amqp:pusher',
       script:   'amqp_daemon.rb',
       arguments: %w[ pusher_market pusher_member ]

daemon 'amqp:trade_executor',
       script:   'amqp_daemon.rb',
       arguments: %w[ trade_executor ]

daemon 'amqp:withdraw_coin',
       script:   'amqp_daemon.rb',
       arguments: %w[ withdraw_coin ]

Dir.glob "#{File.dirname(__FILE__)}/**/*.rb" do |file|
  script = File.basename(file)
  next if %w[ amqp_daemon.rb ].include?(script)
  daemon File.basename(script, '.*'), script: script
end
