# encoding: UTF-8
# frozen_string_literal: true

module AccountingService
  class MemberEntry
    include ActiveModel::Model
    attr_accessor :owner, :currency_id

    def accounts
      @accounts ||= initialize_accounts!
    end

    def chart
      @chart ||=
        AccountingService::Chart.new(owner: owner, currency_id: currency_id)
    end

    def initialize_accounts!
      chart.codes.map do |code|
        Account.find_or_create_by!(
          member:       owner,
          currency_id:  currency_id,
          code:         code
        )
      end
    end

  private
    def account(options={})
      codes = chart.codes(options)
      accounts.find_by(code: codes)
    end
  end
end
