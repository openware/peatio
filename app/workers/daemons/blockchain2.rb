# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module Daemons
    class Blockchain2 < Base
      class Runner
        attr_reader :updated_at, :thread

        def initialize(blockchain, ts)
          @blockchain = blockchain
          @updated_at = ts
          @thread = nil
        end

        def start
          @thread ||= Thread.new do
            i = 0

            Rails.logger.info { "Started Processing #{@blockchain.name} blocks." }

            loop do
              Rails.logger.info { "Running #{@blockchain.key} #{i}" }

              sleep 2
              i += 1
            end
          end
        end

        def stop
          Rails.logger.warn { "Okay we are done #{@blockchain.name}. See you" }
          @thread&.kill
        end
      end


      # TODO: Start synchronization of blockchains created in run-time.
      def run
        @runner_pool = ::Blockchain.active.each_with_object({}) do |b, pool|
          max_updated_at = [b.currencies.maximum(:updated_at), b.updated_at].compact.max

          pool[b.key] = Runner.new(b, max_updated_at).tap(&:start)
        end

        while running
          (@runner_pool.keys - ::Blockchain.active.pluck(:key)).each do |b_key|
            Rails.logger.warn { "Stopping the runner for #{b_key} (blockchain is not active anymore)" }
            @runner_pool.delete(b_key).stop
          end

          ::Blockchain.active.each do |b|
            max_updated_at = [b.currencies.maximum(:updated_at), b.updated_at].compact.max

            if @runner_pool[b.key].blank?
              Rails.logger.warn { "Starting the new runner for #{b.key} (no runner found in pool)" }
              @runner_pool[b.key] = Runner.new(b, max_updated_at).tap(&:start)
            elsif @runner_pool[b.key].updated_at < max_updated_at
              Rails.logger.warn { "Recreating a runner for #{b.key} (#{@runner_pool[b.key].updated_at} < #{max_updated_at})" }
              @runner_pool.delete(b.key).stop
              @runner_pool[b.key] = Runner.new(b, max_updated_at).tap(&:start)
            else
              Rails.logger.warn { "The runner for #{b.key} is up to date (#{@runner_pool[b.key].updated_at} >= #{max_updated_at})" }
            end
          end

          sleep 5
        end
      end

      def stop
        @running = false
        @runner_pool.each { |_bc_key, runner| runner.stop }
      end
    end
  end
end
