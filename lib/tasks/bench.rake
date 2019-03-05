# frozen_string_literal: true

namespace :bench do
  desc 'Matching'
  task :matching, [:config_load_path] => [:environment] do |t, args|
    args.with_defaults(:config_load_path => 'config/bench/matching.yml')

    matching = Bench::Matching.new(args[:config_load_path])
    matching.run!

    # Temporary just print benchmark results.
    Kernel.puts matching.result
  end
end
