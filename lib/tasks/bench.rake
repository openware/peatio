# frozen_string_literal: true

# TODO: Add descriptions.
# TODO: Save reports directly after running bench (in case next will error).
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
          Kernel.puts "Sleep before next bench"
          sleep 5
        end

    benches.each {|b| Kernel.pp b.result}
  end

  desc 'Trade Execution'
  task :trade_execution, [:config_load_path] => [:environment] do |_t, args|
    args.with_defaults(:config_load_path => 'config/bench/trade_execution.yml')

    benches =
      YAML.load_file(Rails.root.join(args[:config_load_path]))
        .map(&:deep_symbolize_keys)
        .each_with_object([]) do |config, memo|
        Kernel.pp config

        trade_execution = Bench::TradeExecution.new(config)
        trade_execution.run!
        memo << trade_execution
        Kernel.puts "Sleep before next bench"
        sleep 5
      end

    benches.each {|b| Kernel.pp b.result}
  end

  desc 'Order Processing'
  task :order_processing, [:config_load_path] => [:environment] do |_t, args|
    args.with_defaults(:config_load_path => 'config/bench/order_processing.yml')

    benches =
      YAML.load_file(Rails.root.join(args[:config_load_path]))
        .map(&:deep_symbolize_keys)
        .each_with_object([]) do |config, memo|
        Kernel.pp config

        order_processing = Bench::OrderProcessing.new(config)
        order_processing.run!
        memo << order_processing
        Kernel.puts "Sleep before next bench"
        sleep 5
      end

    benches.each {|b| Kernel.pp b.result}
  end
end
