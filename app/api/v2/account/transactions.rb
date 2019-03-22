# encoding: UTF-8
# frozen_string_literal: true

require_relative '../validations'

module API
  module V2
    module Account
      class Transactions < Grape::API

        before { deposits_must_be_permitted! }
        before { withdraws_must_be_permitted! }

        desc 'Get your transactions history.',
          is_array: true,
          success: API::V2::Entities::Transaction

        params do
          optional :currency,
                   type: String,
                   values: { value: -> { Currency.enabled.codes(bothcase: true) }, message: 'account.currency.doesnt_exist' },
                   desc: 'Currency code'

          # TODO: add params for sorting
        end
        get "/transactions" do
          currency = Currency.find(params[:currency]) if params[:currency].present?

          deposits  = currency ? current_user.deposits.where(currency: currency) : current_user.deposits
          withdraws = currency ? current_user.withdraws.where(currency: currency) : current_user.withdraws

          present (deposits + withdraws), with: API::V2::Entities::Transaction
        end

      end
    end
  end
end
