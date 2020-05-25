class CurrencyWallet < ApplicationRecord
  self.table_name = 'currencies_wallets'

  belongs_to :currency
  belongs_to :wallet
  validates :currency_id, uniqueness: { scope: :wallet_id }
end
