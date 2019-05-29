# encoding: UTF-8
# frozen_string_literal: true

# This daemon is temporary solution for updating legacy Account balance
# and locked columns.
# It will be removed once we replace Account model with Operations::Liability.
# For now we just recalculate periodically account balances using
# liability history.

require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')

running = true
Signal.trap(:TERM) { running = false }

liabilities_was = 0

while running
  loop do
    liabilities_number = Operations::Liability.count
    if liabilities_was != liabilities_number
      [
        "Liabilities number was #{liabilities_was} and now it's #{liabilities_number}",
        "Recalculating member balances"
      ].join("\n").tap { |m| Rails.logger.debug m }
      liabilities_was = liabilities_number
      break
    end
    [
      "Liabilities number didn't change since last update",
      "Skip balance recalculating"
    ].join("\n").tap { |m| Rails.logger.debug m }
    sleep 0.5
  end

  Currency.find_each do |currency|
    main_liability_code = Operations::Account.find_by(
      type:          :liability,
      kind:          :main,
      currency_type: currency.type
    ).code

    locked_liability_code = Operations::Account.find_by(
      type:          :liability,
      kind:          :locked,
      currency_type: currency.type
    ).code

    Account.where(currency: currency).find_in_batches do |accounts_group|
      ActiveRecord::Base.transaction do
        accounts_group.each do |legacy_account|
          balance = Operations::Liability.where(code:        main_liability_code,
                                                member_id:   legacy_account.member_id,
                                                currency_id: currency.id)
                                         .sum('credit - debit')

          locked = Operations::Liability.where(code:        locked_liability_code,
                                               member_id:   legacy_account.member_id,
                                               currency_id: currency.id)
                                        .sum('credit - debit')

          if legacy_account.balance != balance || legacy_account.locked != locked
            update_message = [
              "Updated account:",
              legacy_account.as_json_for_event_api
            ]
            legacy_account.update!(balance: balance, locked: locked)
            update_message << legacy_account.as_json_for_event_api

            Rails.logger.info update_message.join("\n")
          end
        end
      end
    end
  end
end
