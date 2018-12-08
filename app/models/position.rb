class Position < ActiveRecord::Base
end

# == Schema Information
# Schema version: 20181206193050
#
# Table name: positions
#
#  id         :integer          not null, primary key
#  member_id  :integer          not null
#  market_id  :string(20)       not null
#  volume     :integer          default(0), not null
#  price      :decimal(32, 16)  default(0.0), not null
#  margin     :decimal(32, 16)  default(0.0), not null
#  credit     :decimal(32, 16)  default(0.0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_positions_on_member_id_and_market_id  (member_id,market_id) UNIQUE
#
