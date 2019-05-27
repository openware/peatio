# encoding: UTF-8
# frozen_string_literal: true

module Abilities
    # include CanCan::Ability

  class << self
    def new(member)
      # binding.pry
      if member.role.admin?
        Abilities::AdminAbility.new(member)
      end
    end
    # def initialize(user)
    #   # return unless user.admin?

    #   can :manage, :all if user.role == "superadmin"

    #   if user.admin?
    #     can :read, Order
    #     can :read, Trade
    #     can :manage, Member

    #     can :menu, Deposit
    #     Deposit.descendants.each { |d| can :manage, d }

    #     can :menu, Withdraw
    #     Withdraw.descendants.each { |w| can :manage, w }

    #     can :menu, Operation
    #     Operation.descendants.each { |o| can :manage, o }

    #     can :manage, Market
    #     can :manage, Currency
    #     can :manage, Blockchain
    #     can :manage, Wallet
    #   end
  end
end
