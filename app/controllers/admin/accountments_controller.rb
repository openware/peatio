# encoding: UTF-8
# frozen_string_literal: true

module Admin
  class AccountmentsController < BaseController
    load_and_authorize_resource
    helper_method :tabs
    
    def withdraws
      @withdraws = Withdraw.all.order('id desc').page(params[:page]).per(20)
    end

    def users
      @members = Member.all.order('id desc').page(params[:page]).per(20)
    end

    private

    def tabs
      { withdraw: ['admin.accountments.tabs.withdraw', admin_accountments_withdraws_path]
      }
    end
  end
end
