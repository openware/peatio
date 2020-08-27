# frozen_string_literal: true

class WithdrawLimit < ApplicationRecord

  # Default value for kyc_level, group name and currency_id in WithdrawLimit table;
  ANY = 'any'

    # == Attributes ===========================================================

  # == Extensions ===========================================================

  # == Relationships ========================================================

  belongs_to :currency, optional: true

  # == Validations ==========================================================

  validates :kyc_level,
            presence: true,
            uniqueness: { scope: %i[currency_id group] }

  validates :group,
            presence: true

  validates :currency_id,
            presence: true,
            inclusion: { in: ->(_fs){ Currency.ids.append(ANY) } }

  validates :limit_24_hour,
            :limit_1_month,
            presence: true

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  before_create { self.group = self.group.strip.downcase }
  after_commit :wipe_cache

  # == Class Methods ========================================================
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

  # == Instance Methods =====================================================

  # Withdraw limit suitability expressed in weight.
  # Withdraw limit with the greatest weight selected.
  # Kyc_level has greater weight then group and group has greater weight then currency_id match.
  # E.g Withdrawal for member with kyc_level 2, group 'vip-0' and currency_id 'btc'
  # (kyc_level == 3     && group == 'vip-0' && currency_id == 'btc') >
  # (kyc_level == 3     && group == 'vip-0' && currency_id == 'any') >
  # (kyc_level == 3     && group == 'any'   && currency_id == 'btc') >
  # (kyc_level == 'any' && group == 'vip-0' && currency_id == 'btc') >
  # (kyc_level == 'any' && group == 'vip-0' && currency_id == 'any') >
  # (kyc_level == 'any' && group == 'any'   && currency_id == 'btc') >
  # (kyc_level == 'any' && group == 'any'   && currency_id == 'any') >
  def weight
    (kyc_level == 'any' ? 0 : 100) + (group == 'any' ? 0 : 10) + (currency_id == 'any' ? 0 : 1)
  end

  def wipe_cache
    Rails.cache.delete_matched("withdraw_limits_fees*")
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
