# namespace :market do
#   task add_order: :environment do
#     market  = Market.first
#     dv      = rand(0.5)
#     dv2     = rand(0.5)
#     price   = [*1..999].sample
#
#     order = Order.create(bid: market.quote_unit,
#                          ask: market.base_unit,
#                          currency: market.id,
#                          price: price,
#                          source: 'APIv2',
#                          volume: dv,
#                          origin_volume: dv2,
#                          state: 'wait',
#                          type: 'OrderAsk',
#                          member_id: 1,
#                          ord_type: 'limit',
#                          locked: dv,
#                          origin_locked: dv)
#
#     puts "!!!!ADDED NEW ORDER WITH ID=#{order.id}!!!!"
#     puts "Price:#{order.price}"
#     puts "Volume::#{order.volume}"
#     puts "Origin volume::#{order.origin_volume}"
#     puts "Created at:#{order.created_at}"
#     puts "Updated at:#{order.updated_at}"
#     puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
#   end
# end
