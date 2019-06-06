# encoding: UTF-8
# frozen_string_literal: true

module Abilities
  class Support
    include CanCan::Ability

    def initialize
      can :read, Member
      can :read, Deposit
      can :read, Withdraw
      can :read, Account
      can :read, PaymentAddress
    end
  end
end
