class Position < ActiveRecord::Base
  include BelongsToMarket
  include BelongsToMember

  def pnl
    credit + volume * Global[market_id].ticker[:last]
  end

  def lose
    _ = pnl
    (_.abs - _) / 2
  end

  def dmargin(dcredit)
    _ = market.margin_rate * (credit + dcredit).abs - margin + lose
    (_.abs - _) / 2
  end
end

# == Schema Information
# Schema version: 20181211212810
#
# Table name: positions
#
#  id         :integer          not null, primary key
#  member_id  :integer          not null
#  market_id  :string(20)       not null
#  volume     :integer          default(0), not null
#  margin     :decimal(32, 16)  default(0.0), not null
#  credit     :decimal(32, 16)  default(0.0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_positions_on_member_id_and_market_id  (member_id,market_id) UNIQUE
#
