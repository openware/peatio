# frozen_string_literal: true

class WithdrawLimit < ApplicationRecord

  # Default value for kyc_level, group name and currency_id in WithdrawLimit table;
  ANY = 'any'

  class << self
    # Get withdrawal limit for specific withdraw that based on member kyc_level, group and currency_id.
    # WithdrawLimit record selected with the next priorities:
    #  1. kyc_level, group and currency_id match
    #  2. kyc_level match
    #  3. group match
    #  4. currency_id match
    #  5. kyc_level, group and currency_id are 'any'
    #  6. default (zero limits)
    def for(kyc_level:, group:, currency_id:)
      WithdrawLimit
        .where(kyc_level: [kyc_level, ANY], currency_id: [currency_id, ANY], group: [group, ANY])
        .max_by(&:weight) || WithdrawLimit.new
    end
  end

  def weight
    (kyc_level == 'any' ? 0 : 100) + (group == 'any' ? 0 : 10) + (currency_id == 'any' ? 0 : 1)
  end
end

# == Schema Information
# Schema version: 20200827105929
#
# Table name: withdraw_limits
#
#  id            :bigint           not null, primary key
#  currency_id   :string(20)       default("any"), not null
#  group         :string(32)       default("any"), not null
#  kyc_level     :string(32)       default("any"), not null
#  limit_24_hour :decimal(32, 16)  default(0.0), not null
#  limit_1_month :decimal(32, 16)  default(0.0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_withdraw_limits_on_currency_id                          (currency_id)
#  index_withdraw_limits_on_currency_id_and_group_and_kyc_level  (currency_id,group,kyc_level) UNIQUE
#  index_withdraw_limits_on_group                                (group)
#  index_withdraw_limits_on_kyc_level                            (kyc_level)
#
