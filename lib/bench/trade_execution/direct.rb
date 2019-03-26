# frozen_string_literal: true

module Bench
  module TradeExecution
    class Direct
      def run!
        # TODO: Check if TradeExecutor daemon is running before start (use queue_info[:consumers]).
        Kernel.puts 'Waiting for trades processing by trade execution daemon...'
        @execution_started_at = @publish_started_at
        process_messages
        @execution_finished_at = Time.now
      end

      def process_messages
        matching = Worker::Matching.new
        loop do
          order = @injector.pop
          break unless order
          matching.process({action: 'submit', order: order.to_matching_attributes}, 'lol', 'kek')
        rescue StandardError => e
          Kernel.puts e
          @errors << e
        end
      end

      def result
        @result ||=
          begin
            trades_number = Trade.where('created_at >= ?', @publish_started_at).length
            trades_ops = trades_number / (@execution_finished_at - @execution_started_at)

            super.merge(
              trade_execution: {
                started_at:  @execution_started_at.iso8601(6),
                finished_at: @execution_finished_at.iso8601(6),
                operations:  trades_number,
                ops:         trades_ops
              }
            )
          end
      end
    end
  end
end
