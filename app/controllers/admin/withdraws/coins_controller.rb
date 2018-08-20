# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'admin/withdraws/base_controller'

module Admin
  module Withdraws
    class CoinsController < BaseController
      before_action :find_withdraw, only: [:show, :update, :destroy]

      def index
        @latest_withdraws  = ::Withdraws::Coin.where(currency: currency)
                                              .where('created_at <= ?', 1.day.ago)
                                              .order(id: :desc)
                                              .includes(:member)
                                              .includes(:currency)
        @all_withdraws     = ::Withdraws::Coin.where(currency: currency)
                                              .where('created_at > ?', 1.day.ago)
                                              .order(id: :desc)
                                              .includes(:member)
                                              .includes(:currency)
      end

      def show

      end

      def update
        @withdraw.transaction do
          @withdraw.update!(txid: params[:withdraw][:txid]) unless params[:withdraw][:txid].blank?
          @withdraw.accept!
          @withdraw.process!
          @withdraw.dispatch! unless @withdraw.txid.blank?
        end
        redirect_to :back, notice: t('admin.withdraws.coins.update.notice')

      rescue ActiveRecord::RecordInvalid
        flash.now[:alert] = @withdraw.errors.full_messages
        render :show
      end

      def destroy
        @withdraw.reject!
        redirect_to :back, notice: t('admin.withdraws.coins.update.notice')
      end
    end
  end
end
