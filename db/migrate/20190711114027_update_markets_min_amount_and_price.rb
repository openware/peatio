class UpdateMarketsMinAmountAndPrice < ActiveRecord::Migration[5.2]
  def change
    Market.find_each do |m|
      m.update!(min_amount: m.min_amount_by_precision)
      m.update!(min_price: m.min_price_by_precision)
    end
  end
end
