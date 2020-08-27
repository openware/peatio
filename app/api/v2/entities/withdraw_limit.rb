module API
  module V2
    module Entities
      class TradingFee < API::V2::Entities::Base
        expose(
          :id,
          documentation:{
            type: Integer,
            desc: 'Unique withdraw limit table identifier in database.'
          }
        )

        expose(
          :group,
          documentation:{
            type: String,
            desc: 'Member group for define withdraw limits.'
          }
        )

        expose(
          :currency_id,
          documentation:{
            type: String,
            desc: 'Currency id for define withdraw limits.'
          }
        )

        expose(
          :kyc_level,
          documentation:{
            type: String,
            desc: 'KYC level for define withdraw limits.'
          }
        )

        expose(
          :l24hour,
          documentation:{
            type: BigDecimal,
            desc: '24 hours withdraw limit.'
          }
        )

        expose(
          :l1month,
          documentation:{
            type: BigDecimal,
            desc: '1 month withdraw limit.'
          }
        )

        expose(
          :created_at,
          format_with: :iso8601,
          documentation: {
            type: String,
            desc: 'Withdraw limit table created time in iso8601 format.'
          }
        )

        expose(
          :updated_at,
          format_with: :iso8601,
          documentation: {
            type: String,
            desc: 'Withdraw limit table updated time in iso8601 format.'
          }
        )
      end
    end
  end
end
