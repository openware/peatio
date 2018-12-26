# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  module Entities
    class Currency < Base
      expose :id, documentation: 'Currency code'
      expose :symbol, documentation: 'Currency symbol'
      expose :type, documentation: 'Currency type. Available values: coin or fiat'

      expose :wallet_url_template, if: -> (currency){ currency.coin? },
              documentation: 'Currency address exporer url template'
      expose :transaction_url_template, if: -> (currency){ currency.coin? },
              documentation: 'Currency transactions exporer url template'

      expose :deposit_fee, documentation: 'Currency deposit fee'
      expose :withdraw_fee, documentation: 'Currency withdraw fee'

      expose :min_withdraw_amount, documentation: 'Currency min withdraw amount'
      expose :quick_withdraw_limit, documentation: 'Currency quick withdraw limit'
      expose :deposit_confirmations, if: -> (currency){ currency.type == 'coin' },
             documentation: 'Number of deposit confirmations for currency'

      expose :base_factor, documentation: 'Currency base factor'
      expose :precision, documentation: 'Currency precision'
    end
  end
end
