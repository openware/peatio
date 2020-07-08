# frozen_string_literal: true

module Jobs
  module Cron
    class Archive
      def self.process
        # ORDER_MAX_AGE in minutes
        order_max_age = ENV.fetch('ORDER_MAX_AGE', 40320)

        # Cancel orders that older than max_order_age
        Order.where('created_at > ? AND state = ?', Time.now - order_max_age, 100).each do |o|
          Order.cancel(o.id)
        end

        yaml = ::Pathname.new("config/database.yml")
        return {} unless yaml.exist?

        config = ::SafeYAML.load(::ERB.new(yaml.read).result)['archive_production']

        return if config.blank?

        time = Time.now
        statement = ActiveRecord::Base.connection.raw_connection.prepare('SELECT * FROM `orders` WHERE updated_at < DATE_SUB(?, INTERVAL 1 WEEK) AND state = -100 AND trades_count = 0;')
        result = statement.execute(time)

        # Connection to the archive database
        archive_database = Mysql2::Client.new(config)
        # TODO: Write orders to the archive database
        # TODO: Delete after

        # Execute sp.sql
        ActiveRecord::Base.connection.execute("call compact_liabilities('2020-07-28 00:00:00','2020-07-28 23:59:59')")
      end
    end
  end
end
