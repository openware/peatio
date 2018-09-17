# encoding: UTF-8
# frozen_string_literal: true

module Admin
  class AccountmentsController < BaseController
    load_and_authorize_resource
    helper_method :tabs

    def withdraws
      @withdraws = Withdraw.all.order('id desc').page(params[:page]).per(20)
    end

    def members
      @members = Member.all.order('id desc').page(params[:page]).per(20)
    end

    def trades
      @trades = Trade.all.order('id desc').page(params[:page]).per(20)
    end

    def orders
      @orders = Order.all.order('id desc').page(params[:page]).per(20)
    end

    def deposits
      @deposits = Deposit.all.page(params[:page]).per(20)
    end

    private

    def tabs
      { deposit:  ['admin.accountments.tabs.deposit', deposits_admin_accountments_path],
        withdraw: ['admin.accountments.tabs.withdraw', withdraws_admin_accountments_path],
        member:   ['admin.accountments.tabs.member', members_admin_accountments_path],
        trade:    ['admin.accountments.tabs.trade', trades_admin_accountments_path],
        order:    ['admin.accountments.tabs.order', orders_admin_accountments_path]
      }
    end
  end
end
