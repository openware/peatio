# frozen_string_literal: true

namespace :bench do
  desc 'Matching'
  task :matching, [:config_load_path] => [:environment] do |_t, args|
    args.with_defaults(:config_load_path => 'config/bench/matching.yml')

    benches =
      YAML.load_file(Rails.root.join(args[:config_load_path]))
        .map(&:deep_symbolize_keys)
        .each_with_object([]) do |config, memo|
          Kernel.pp config

          matching = Bench::Matching.new(config)
          matching.run!
          memo << matching
        end

    benches.each {|b| Kernel.pp b.result}
  end
end
