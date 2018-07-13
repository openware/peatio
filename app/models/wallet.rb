# encoding: UTF-8
# frozen_string_literal: true

# TODO: Add specs.
class Wallet < ActiveRecord::Base
  include BelongsToCurrency

  # TODO: Add validations.
  scope :active, -> { where(status: 'active') }
end

# == Schema Information
# Schema version: 20180708171446
#
# Table name: wallets
#
#  id          :integer          not null, primary key
#  currency_id :string(5)
#  name        :string(64)
#  address     :string(255)      not null
#  kind        :string(32)       not null
#  nsig        :integer
#  parent      :integer
#  status      :string(32)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
