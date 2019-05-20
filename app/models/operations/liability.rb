# frozen_string_literal: true

module Operations
  # {Liability} is a balance sheet operation
  class Liability < Operation
    belongs_to :member

    validates :member_id, presence: {
      if: ->(liability) { liability.account.scope == 'member' }
    }

    validates :member_id, absence: {
      if: ->(liability) { liability.account.scope != 'member' }
    }

    after_create do |liability|
      AMQPQueue.enqueue(
        :order_processor,
        subject: 'operation',
        payload: liability.to_matching_attributes,
      )
    end

    def to_matching_attributes
      {
        code:           code,
        currency:       currency.id,
        member_id:      (member.nil?) ? nil : member.id,
        reference_id:   (reference.nil?) ? nil : reference.id,
        reference_type: reference_type.to_s.downcase,
        debit:          debit,
        credit:         credit,
      }
    end
  end
end

# == Schema Information
# Schema version: 20190110164859
#
# Table name: liabilities
#
#  id             :integer          not null, primary key
#  code           :integer          not null
#  currency_id    :string(255)      not null
#  member_id      :integer
#  reference_id   :integer
#  reference_type :string(255)
#  debit          :decimal(32, 16)  default(0.0), not null
#  credit         :decimal(32, 16)  default(0.0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_liabilities_on_currency_id                      (currency_id)
#  index_liabilities_on_member_id                        (member_id)
#  index_liabilities_on_reference_type_and_reference_id  (reference_type,reference_id)
#
