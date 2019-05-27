# encoding: UTF-8
# frozen_string_literal: true

module Abilities
  class AdminAbility
    include CanCan::Ability

    def initialize(user)
      can :read, Order
      can :read, Trade
      can :manage, Member

      can :menu, Deposit
      Deposit.descendants.each { |d| can :manage, d }

      can :menu, Withdraw
      Withdraw.descendants.each { |w| can :manage, w }

      can :menu, Operation
      Operation.descendants.each { |o| can :manage, o }

      can :manage, Market
      can :manage, Currency
      can :manage, Blockchain
      can :manage, Wallet
      # can :manage, Account
      # can :manage, PaymentAddress
    end
  end
end
