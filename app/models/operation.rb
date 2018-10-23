class Operation < ActiveRecord::Base
    belongs_to :account, required: true
end

# == Schema Information
# Schema version: 20181023073457
#
# Table name: operations
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  debit      :decimal(32, 16)  default(0.0), not null
#  credit     :decimal(32, 16)  default(0.0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
