# encoding: UTF-8
# frozen_string_literal: true

module ManagementAPIv1
  module Entities
    class Market < Base
      expose :name, documentation: { type: String, desc: 'Market name' }
      expose :id, documentation: { type: String, desc: 'Market id.' }
      expose :ask_unit, documentation: { type: String, desc: 'Market ask unit' }
      expose :bid_unit, documentation: { type: String, desc: 'Market bid unit' }
      expose :ask_fee, documentation: { type: BigDecimal, desc: 'Market ask fee' }
      expose :bid_fee, documentation: { type: BigDecimal, desc: 'Market bid fee' }
      expose :max_bid, documentation: { type: BigDecimal, desc: 'Market max bid' }
      expose :min_ask, documentation: { type: BigDecimal, default: 0, desc: 'Market min ask' }
      expose :ask_precision, documentation: { type: Integer, desc: 'Market ask precision' }
      expose :bid_precision, documentation: { type: Integer, desc: 'Market bid precision' }
      expose :position, documentation: { type: Integer, desc: 'Market position' }
      expose :enabled, documentation: { type: String, default: true, desc: 'Market status' }
    end
  end
end
