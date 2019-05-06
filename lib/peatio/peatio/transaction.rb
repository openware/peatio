module Peatio
  class Transaction
    include ActiveModel::Model

    STATUSES = %i[success pending fail].freeze

    attr_accessor :hash, :txout,
                  :to_address,
                  :amount,
                  :block_number,
                  :currency_id

    attr_writer :status

    validates :hash, :txout,
              :to_address,
              :amount,
              :block_number,
              :currency_id,
              :status,
              presence: true

    validates :block_number,
              numericality: { greater_than_or_equal_to: 0, only_integer: true }

    validates :amount,
              numericality: { greater_than_or_equal_to: 0 }

    validates :status, inclusion: { in: STATUSES }

    # TODO: rewrite this method
    def status
      @status.to_sym
    end
  end
end
