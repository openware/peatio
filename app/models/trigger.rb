# encoding: UTF-8
# frozen_string_literal: true


class Trigger < ApplicationRecord
  extend Enumerize

  belongs_to :order, required: true

  # Enumerized list of statuses supported by trigger
  #
  # @note
  #   pending(initial,default)
  #   Trigger and order were created and persisted in DB.
  #
  #   active
  #   Trigger was added to triggerbook and waiting for being triggered by trade.
  #
  #   done
  #   Trigger was triggered by trade and thrown appropriate order.
  #
  #   cancelled
  #   Trigger was created but order was rejected by system on creation or
  #   trigger was activated but order was cancelled by user.
  #
  #              (1)              (2)
  #   Pending --------> Active ----------> Done
  #      |                |
  #      |(3)             |(4)
  #      |                |
  #      '------------> Cancelled
  #
  # 1 - add to triggerbook and lock order funds
  # 2 - triggered by trade
  # 3 - reject order on submit
  # 4 - cancel order by user
  STATES = { pending: 0, active: 100, done: 200, cancelled: -100 }.freeze

  # TODO: Add trigger types description.
  TYPES = %i[stop trailing_stop oco].freeze

  enumerize :state, in: STATES, scope: true

  validates :price, numericality: { greater_than: 0 }

  # Disable STI so we can use type column.
  self.inheritance_column = true

  validates :type, inclusion: { in: TYPES }
end

# == Schema Information
# Schema version: 20190529142209
#
# Table name: triggers
#
#  id         :bigint(8)        not null, primary key
#  order_id   :bigint(8)        not null
#  price      :decimal(32, 16)  default(0.0), not null
#  state      :integer          default("pending"), not null
#  type       :string(10)       not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_triggers_on_order_id  (order_id)
#  index_triggers_on_state     (state)
#  index_triggers_on_type      (type)
#
