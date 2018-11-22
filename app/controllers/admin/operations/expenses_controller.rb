# encoding: UTF-8
# frozen_string_literal: true

module Admin
  module Operations
    class ExpensesController < BaseController
      def index
        @expenses = ::Operations::Expense.includes(:reference, :currency)
                        .order(id: :desc)
                        .page(params[:page])
                        .per(20)
      end
    end
  end
end
