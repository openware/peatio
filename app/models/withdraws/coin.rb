module Withdraws
  class Coin < Withdraw
    before_validation { self.rid  = rid.try(:downcase) if currency&.case_insensitive? }
    before_validation { self.rid  = CashAddr::Converter.to_legacy_address(rid) if currency&.code&.bch? }
    before_validation { self.txid = txid.try(:downcase) if currency&.case_insensitive? }

    def wallet_url
      if currency.wallet_url_template?
        currency.wallet_url_template.gsub('#{address}', rid)
      end
    end

    def transaction_url
      if txid? && currency.transaction_url_template?
        currency.transaction_url_template.gsub('#{txid}', txid)
      end
    end

    def audit!
      inspection = currency.api.inspect_address!(rid)

      if inspection[:is_valid] == false
        Rails.logger.info "#{self.class.name}##{id} uses invalid address: #{rid.inspect}"
        reject!
      else
        super
      end
    end

    def as_json(*)
      super.merge \
        wallet_url:      wallet_url,
        transaction_url: transaction_url
    end
  end
end

# == Schema Information
# Schema version: 20180406185130
#
# Table name: withdraws
#
#  id          :integer          not null, primary key
#  account_id  :integer
#  member_id   :integer
#  currency_id :integer
#  amount      :decimal(32, 16)
#  fee         :decimal(32, 16)
#  created_at  :datetime
#  updated_at  :datetime
#  done_at     :datetime
#  txid        :string(255)
#  aasm_state  :string
#  sum         :decimal(32, 16)  default(0.0), not null
#  type        :string(255)
#  tid         :string(64)       not null
#  rid         :string(64)       not null
#
# Indexes
#
#  index_withdraws_on_currency_id  (currency_id)
#
