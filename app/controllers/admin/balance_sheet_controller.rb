# encoding: UTF-8
# frozen_string_literal: true

module Admin
  class BalanceSheetController < BaseController
    def index
      @assets = ::Operations::Asset.group(:currency_id).sum(:credit)
      @liabilities = ::Operations::Liability.group(:currency_id).sum(:debit)
      @balances = @assets.merge(@liabilities){ |k, a, b| a - b}
    end
  end
end
