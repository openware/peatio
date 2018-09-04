# encoding: UTF-8
# frozen_string_literal: true

module ManagementAPIv1
  module Entities
    class Wallet < Base
      expose :id, documentation: { type: Integer, desc: 'Wallet id' }
      expose :currency_id, documentation: { type: String, desc: 'Currency id' }
      expose :blockchain_key, documentation: { type: String, desc: 'Blockachain key' }
      expose :name, documentation: { type: String, desc: 'Wallet name' }
      expose :address, documentation: { type: String, desc: 'Wallet adress' }
      expose :max_balance, documentation: { type: BigDecimal, desc: 'Wallet max balance' }
      expose :kind, documentation: { type: String, desc: 'Wallet kind' }
      expose :nsig, documentation: { type: Integer, desc: 'Wallet number of signatures' }
      expose :parent, documentation: { type: String, desc: 'Wallet parent' }
      expose :status, documentation: { type: String, desc: 'Wallet status' }
      expose :gateway, documentation: { type: String, desc: 'Wallet gateway' }
      expose :settings, documentation: { desc: 'Wallet settings' }
    end
  end
end
