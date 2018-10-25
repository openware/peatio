# encoding: UTF-8
# frozen_string_literal: true

class Operation < ActiveRecord::Base
  belongs_to :account,   required: true
  belongs_to :reference, polymorphic: true, required: true
end

# == Schema Information
# Schema version: 20181023073457
#
# Table name: operations
#
#  id             :integer          not null, primary key
#  account_id     :integer          not null
#  reference_id   :integer          not null
#  reference_type :string(255)      not null
#  debit          :decimal(32, 16)  default(0.0), not null
#  credit         :decimal(32, 16)  default(0.0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_operations_on_account_id                       (account_id)
#  index_operations_on_reference_type_and_reference_id  (reference_type,reference_id)
#
