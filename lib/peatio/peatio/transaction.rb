module Peatio
  class Transaction
    include ActiveModel::Model

    STATUSES = %i[success pending fail].freeze

    attr_accessor :hash, :txout,
                  :to_address,
                  :amount,
                  :block_number,
                  :currency_id,
                  :status

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

# txid:           deposit_txs[:id],
# address:        entry[:address],
# amount:         entry[:amount],
# member:         payment_address.account.member,
# currency:       payment_address.currency,
# txout:          entry[:txout],
# block_number:   deposit_txs[:block_number]
#
# txid:           withdraw_txs[:id],
# rid:            entry[:address],
# amount:         entry[:amount],
# block_number:   withdraw_txs[:block_number]
