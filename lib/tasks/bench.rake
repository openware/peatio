# frozen_string_literal: true

# TODO: Add descriptions.
# TODO: Don't sleep in case of last bench.
# TODO: Remove legacy benchmarks.
namespace :bench do
  desc 'Matching'  
  task :amqp_matching, [:config_load_path] => [:environment] do |_t, args|
    args.with_defaults(:config_load_path => 'config/bench/matching.yml')

    benches =
      YAML.load_file(Rails.root.join(args[:config_load_path]))
        .map(&:deep_symbolize_keys)
        .each_with_object([]) do |config, memo|
          Kernel.pp config

          matching = Bench::Matching::Someclass.new(config)
          matching.run!
          memo << matching
          matching.save_report
          Kernel.puts "Sleep before next bench"
          sleep 5
        end

    benches.each {|b| Kernel.pp b.result}
  end

  task :direct_matching, [:config_load_path] => [:environment] do |_t, args|
    args.with_defaults(:config_load_path => 'config/bench/matching.yml')

    benches =
      YAML.load_file(Rails.root.join(args[:config_load_path]))
        .map(&:deep_symbolize_keys)
        .each_with_object([]) do |config, memo|
          Kernel.pp config

          matching = Bench::Matching::Direct.new(config)
          matching.run!
          memo << matching
          matching.save_report
          Kernel.puts "Sleep before next bench"
          sleep 5
        end

    benches.each {|b| Kernel.pp b.result}
  end

  desc 'Trade Execution'
  task :amqp_trade_execution, [:config_load_path] => [:environment] do |_t, args|
    args.with_defaults(:config_load_path => 'config/bench/trade_execution.yml')

    benches =
      YAML.load_file(Rails.root.join(args[:config_load_path]))
        .map(&:deep_symbolize_keys)
        .each_with_object([]) do |config, memo|
        Kernel.pp config

        trade_execution = Bench::TradeExecution::Someclass.new(config)
        trade_execution.run!
        memo << trade_execution
        trade_execution.save_report
        Kernel.puts "Sleep before next bench"
        sleep 5
      end

    benches.each {|b| Kernel.pp b.result}
  end

  task :direct_trade_execution, [:config_load_path] => [:environment] do |_t, args|
    args.with_defaults(:config_load_path => 'config/bench/trade_execution.yml')

    benches =
      YAML.load_file(Rails.root.join(args[:config_load_path]))
        .map(&:deep_symbolize_keys)
        .each_with_object([]) do |config, memo|
        Kernel.pp config

        trade_execution = Bench::TradeExecution::Direct.new(config)
        trade_execution.run!
        memo << trade_execution
        trade_execution.save_report
        Kernel.puts "Sleep before next bench"
        sleep 5
      end

    benches.each {|b| Kernel.pp b.result}
  end

  desc 'Order Processing'
  task :amqp_order_processing, [:config_load_path] => [:environment] do |_t, args|
    args.with_defaults(:config_load_path => 'config/bench/order_processing.yml')

    benches =
      YAML.load_file(Rails.root.join(args[:config_load_path]))
        .map(&:deep_symbolize_keys)
        .each_with_object([]) do |config, memo|
        Kernel.pp config

        order_processing = Bench::OrderProcessing::Someclass.new(config)
        order_processing.run!
        memo << order_processing
        order_processing.save_report
        Kernel.puts "Sleep before next bench"
        sleep 5
      end

    benches.each {|b| Kernel.pp b.result}
  end

  task :direct_order_processing, [:config_load_path] => [:environment] do |_t, args|
    args.with_defaults(:config_load_path => 'config/bench/order_processing.yml')

    benches =
      YAML.load_file(Rails.root.join(args[:config_load_path]))
        .map(&:deep_symbolize_keys)
        .each_with_object([]) do |config, memo|
        Kernel.pp config

        order_processing = Bench::OrderProcessing::Direct.new(config)
        order_processing.run!
        memo << order_processing
        order_processing.save_report
        Kernel.puts "Sleep before next bench"
        sleep 5
      end

    benches.each {|b| Kernel.pp b.result}
  end
end
