# encoding: UTF-8
# frozen_string_literal: true

class Fee < ActiveRecord::Base
  belongs_to :fee_chargeable, polymorphic: true
  belongs_to :account

  # We call it after order/withdraw/deposit execution.
  def charge_funds!

  end

  # We call it after order/withdraw/deposit creation.
  def lock_funds!

  end

  # We call it if order was cancelled or withdraw failed.
  def unlock_funds!

  end
end

# == Schema Information
# Schema version: 20180926151351
#
# Table name: fees
#
#  id                  :integer          not null, primary key
#  fee_chargeable_id   :integer
#  fee_chargeable_type :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  account_id          :integer
#  amount              :decimal(32, 16)
#
# Indexes
#
#  index_fees_on_fee_chargeable_type_and_fee_chargeable_id  (fee_chargeable_type,fee_chargeable_id)
#
