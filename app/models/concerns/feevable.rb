module Feevable
  extend ActiveSupport::Concern

  included do
    before_validation(on: :create) { calc_fee }

    validates :fee, numericality: { greater_than_or_equal_to: 0 }
    validates :fee, presence: true
  end
end