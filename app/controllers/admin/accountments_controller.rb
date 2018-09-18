# encoding: UTF-8
# frozen_string_literal: true

module Admin
  class AccountmentsController < BaseController
    load_and_authorize_resource
    helper_method :tabs, :sort_column, :sort_direction
    
    def withdraws
      @withdraws = Withdraw.all.order('id desc').page(params[:page]).per(20)
      @withdraws = @withdraws.by_currency_id(params[:currency_id]) if params[:currency_id].present?
      @withdraws = @withdraws.by_aasm_state(params[:aasm_state]) if params[:aasm_state].present?
    end

    def members
      @members = Member.all.order('id desc').page(params[:page]).per(20)
    end

    def trades
      @trades = Trade.all.order('id desc').page(params[:page]).per(20)
      @trades = @trades.by_market_id(params[:market_id]) if params[:market_id].present?
    end

    def orders
      @orders = Order.all.order('id desc').page(params[:page]).per(20)
      @orders = @orders.by_state(params[:state]) if params[:state].present?
      @orders = @orders.by_market_id(params[:market_id]) if params[:market_id].present?
      @orders = @orders.by_bid(params[:bid]) if params[:bid].present?
      @orders = @orders.by_ask(params[:ask]) if params[:ask].present?
    end

    def deposits
      @deposits = Deposit.all.order("#{sort_column} #{sort_direction}").page(params[:page]).per(20)
      @deposits = @deposits.by_currency_id(params[:currency_id]) if params[:currency_id].present?
      @deposits = @deposits.by_aasm_state(params[:aasm_state]) if params[:aasm_state].present?
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

    def sortable_columns
      ["fee", "amount", "address"]
    end
  
    def sort_column
      sortable_columns.include?(params[:column]) ? params[:column] : "fee"
    end
  
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
    
  end
end
