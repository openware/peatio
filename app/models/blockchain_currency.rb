class BlockchainCurrency < ApplicationRecord
  belongs_to :currency
  belongs_to :blockchain, foreign_key: :blockchain_key, primary_key: :key

  scope :ordered, -> { order(id: :asc) }
end
