module Peatio
  class BlockchainAddress
    include ActiveModel::Model

    attr_accessor :address, :secret, :details

    validates :address, presence: true
  end
end
