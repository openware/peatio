# encoding: UTF-8
# frozen_string_literal: true

class WhitelistedSmartContract < ApplicationRecord
  # == Constants ============================================================

  STATES = %w[active disabled].freeze

  # == Relationships ========================================================

  belongs_to :blockchain, foreign_key: :blockchain_key, primary_key: :key

  # == Validations ==========================================================

  validates :address, presence: true, uniqueness: { scope: :blockchain_key }

  validates :blockchain_key,
            presence: true,
            inclusion: { in: ->(_) { Blockchain.pluck(:key).map(&:to_s) } }

  validates :state,  inclusion: { in: STATES }

  # == Scopes ===============================================================

  scope :active, -> { where(state: :active) }
  scope :ordered, -> { order(kind: :asc) }

  after_save :update_blockchain

  def update_blockchain
    blockchain.touch
  end
end
