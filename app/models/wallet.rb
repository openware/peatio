class Wallet < ActiveRecord::Base
  include BelongsToCurrency

  def wallet_url
    if currency.wallet_url_template?
      currency.wallet_url_template.gsub('#{address}', address)
    end
  end
end

# == Schema Information
# Schema version: 20180708171446
#
# Table name: wallets
#
#  id          :integer          not null, primary key
#  currency_id :string(5)
#  name        :string(64)
#  address     :string(255)
#  kind        :string(32)
#  nsig        :integer
#  parent      :integer
#  status      :string(32)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
