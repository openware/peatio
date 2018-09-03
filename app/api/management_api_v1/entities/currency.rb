# encoding: UTF-8
# frozen_string_literal: true

module ManagementAPIv1
  module Entities
    class Currency < Base
      expose :id, documentation: { type: String, desc: 'Currency code' }
      expose :blockchain_key, documentation: { type: String, desc: 'Currency blockchain key' }
      expose :symbol, documentation: { type: String, desc: 'Currency symbol' }
      expose :type, documentation: { type: String, desc: 'Currency type' }
      expose :deposit_fee, documentation: { type: BigDecimal, desc: 'Currency deposit fee' }
      expose :quick_withdraw_limit, documentation: { type: BigDecimal, desc: 'Currency quick withdraw limit' }
      expose :withdraw_fee, documentation: { type: BigDecimal, desc: 'Currency withdraw fee' }
      expose :base_factor, documentation: { type: Integer, desc: 'Currency base factor' }
      expose :precision, documentation: { type: Integer, desc: 'Currency precision' }
      expose :icon_url, documentation: { type: String, desc: 'Currency icon url' }
      expose :enabled, documentation: { type: String, default: true, desc: 'Currency status' }
    end
  end
end
