# encoding: UTF-8
# frozen_string_literal: true

module ManagementAPIv1
  module Entities
    class Blockchain < Base
      expose :key, documentation: { type: String, desc: 'Blockchain key' }
      expose :name, documentation: { type: String, desc: 'Blockchain name' }
      expose :client, documentation: { type: String, desc: 'Blockchain client' }
      expose :server, documentation: { type: String, desc: 'Blockchain server' }
      expose :height, documentation: { type: Integer, desc: 'Blockchain height' }
      expose :explorer_address, documentation: { type: String, desc: 'Blockchain explorer address' }
      expose :explorer_transaction, documentation: { type: String, desc: 'Blockchain explorer transaction' }
      expose :min_confirmations, documentation: { type: Integer, default: 6, desc: 'Minimum confirmations from network' }
      expose :status, documentation: { type: String, desc: 'Blockchain status' }
    end
  end
end
