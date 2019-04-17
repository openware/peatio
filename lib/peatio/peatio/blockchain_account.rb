module Peatio
  class BlockchainAccount
    include ActiveModel::Model

    attr_accessor :address, :secret, :details

    validates :address, presence: true
  end
end
