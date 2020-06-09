module Jobs
  module Cron
    class AML
      def self.process
        Deposit.aml_processing.each do |d|
          d.process_collect! if d.aml_check!
        end

        Beneficiary.aml_processing.each do |b|
          b.enable! if aml_check!
        end
        sleep 60
      end
    end
  end
end
