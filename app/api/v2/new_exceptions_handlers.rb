module API
  module V2

    module NewExceptionsHandlers

      def self.included(base)
        base.instance_eval do
          rescue_from Grape::Exceptions::ValidationErrors do |e|
            errors_array = e.full_messages.map do |err|
              err.split.last
            end
            error!({ errors: errors_array }, 422)
          end

          rescue_from Peatio::Auth::Error do |e|
            report_exception(e)
            error!({ errors: ['jwt.decode_and_verify'] }, 401)
          end

          rescue_from ActiveRecord::RecordNotFound do |_e|
            error!({ errors: ['record.not_found'] }, 404)
          end
        end
      end
    end
  end
end
