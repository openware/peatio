json.asks @asks
json.bids @bids
json.trades @trades

if @member
  json.my_trades @trades_done.map(&:for_notify)
  json.my_orders *([@orders_wait] + Order::ATTRIBUTES)
end
json.markets @markets_data
json.current_market @market
json.gon_variables gon.all_variables
json.market_groups @market_groups
json.member @member || ""
json.member_accounts @member.accounts.map{|acc| {account: acc, currency_obj: {code_text: acc.currency_obj.code_text, visible: acc.currency_obj.try(:visible)}, scope: @market.scope?(acc) }} if @member
