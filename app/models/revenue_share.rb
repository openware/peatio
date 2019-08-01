# encoding: UTF-8
# frozen_string_literal: true

# RevenueShare - model which provides functionality for revenue distribution
# between members.
#
# E.g
# +-----------+-----------+------------------------+-------+---------------------+---+
# | member_id | parent_id | pptt | state | created_at          | updated_at          |
# +-----------+-----------+------+-------+---------------------+---------------------+
# | 3         | 1         | 2000 | 0     | 2019-07-31 13:41:00 | 2019-07-31 13:41:00 |
# | 3         | 2         | 500  | 0     | 2019-07-31 13:41:00 | 2019-07-31 13:41:00 |
# | 5         | 4         | 2500 | 0     | 2019-07-31 13:41:00 | 2019-07-31 13:41:00 |
# | 7         | 6         | 5000 | 1     | 2019-07-31 13:41:00 | 2019-07-31 13:41:00 |
# +-----------+-----------+------+-------+---------------------+---------------------+
# For member 3:
#   20% (2_000/10_000 = 20%) of trading fees will be paid to member with id 1.
#   5%  (500/10_000 = 5%)    of trading fees will be paid to member with id 2.
#   75% (100% - 20% - 5%)    of trading fees will be paid to platform.
#
# For member 5:
#   25% (2_500/10_000 = 25%) of trading fees will be paid to member with id 4.
#   75% (100% - 20% - 5%)    of trading fees will be paid to platform.
#
# For member 7:
#   0% (state is disabled)   of trading fees will be paid to member with id 6.
#   100% (100% - 0% = 100%)  of trading fees will be paid to platform.
#
class RevenueShare < ApplicationRecord
  # == Constants ============================================================

  extend Enumerize

  # Read about parts per ten thousand (pptt, sign ‱) pseudo-unit for better
  # understanding how do we store percents in this model.
  # https://en.wikipedia.org/wiki/Basis_point
  # Per ten thousand is used as a convenient unit of measurement in contexts
  # where percentage scale of less than 1% are discussed.
  # 1‱ = 0.01%
  # 100‱ = 1%
  PERCENT_DENOMINATOR = 100
  PER_TEN_THOUSAND_DENOMINATOR = 10_000

  STATES = %w[active disabled]

  # == Attributes ===========================================================

  # NOTE: Percent fractional part is truncated to 2 numbers because we store it
  # as parts per ten thousand.
  attr_accessor :percent

  alias_attribute :parts_per_ten_thousand, :pptt

  # == Extensions ===========================================================

  enumerize :state, in: { active: 0, disabled: 1 }

  # == Relationships ========================================================

  belongs_to :member, required: true
  belongs_to :parent, class_name: 'Member', foreign_key: :parent_id, required: true

  # == Validations ==========================================================

  validates :state, inclusion: { in: STATES }

  validates :percent,
            numericality: {
              greater_than: 0,
              less_than_or_equal_to: ->(rs) do
                # Use #state& for cases when we have nil state.
                if rs.state&.active?
                  PERCENT_DENOMINATOR - active.where(member: rs.member).sum(&:percent)
                else
                  PERCENT_DENOMINATOR
                end
              end
            }

  validates :pptt,
            numericality: {
              only_integer: true
            }

  # == Scopes ===============================================================

  scope :active, -> { where(state: :active) }

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  class << self
    def apply(trades)
      # TODO: Implement Revenues split.
    end
  end

  # == Instance Methods =====================================================

  # We are trying to follow ActiveModel::Type::Decimal casting behaviour for
  # percent.
  def percent=(p)
    if p.is_a?(Numeric) || p.is_a?(String)
      self.pptt = (p.to_d * PER_TEN_THOUSAND_DENOMINATOR / PERCENT_DENOMINATOR).to_i
    else
      self.pptt = nil
    end
  end

  def percent
    if pptt.is_a?(Numeric)
      pptt.to_d / PER_TEN_THOUSAND_DENOMINATOR * PERCENT_DENOMINATOR
    else
      nil
    end
  end
end

# == Schema Information
# Schema version: 20190730091236
#
# Table name: revenue_shares
#
#  id         :bigint           not null, primary key
#  member_id  :integer          not null
#  parent_id  :integer          not null
#  pptt       :integer          unsigned, not null
#  state      :integer          default("active"), unsigned, not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_revenue_shares_on_member_id            (member_id)
#  index_revenue_shares_on_member_id_and_state  (member_id,state)
#  index_revenue_shares_on_state                (state)
#
