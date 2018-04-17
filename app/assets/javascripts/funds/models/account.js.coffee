class Account extends PeatioModel.Model
  @configure 'Account', 'member_id', 'currency', 'balance', 'locked', 'created_at', 'updated_at', 'in', 'out', 'deposit_address', 'currency_icon_url'

  @initData: (records) ->
    PeatioModel.Ajax.disable ->
      $.each records, (idx, record) ->
        Account.create(record)

<<<<<<< HEAD
  withdraw_channels: ->
    WithdrawChannel.findAllBy 'currency', @currency
=======
  deposit_channels: ->
    DepositChannel.findAllBy 'currency', @currency

  deposit_channel: ->
    DepositChannel.findBy 'currency', @currency
>>>>>>> Remove withdraw_channels in js

  deposits: ->
    Deposit.findAllBy('currency', @currency)

  withdraws: ->
    Withdraw.findAllBy('account_id', @id)

  topDeposits: ->
    @deposits().reverse().slice(0,3)

  topWithdraws: ->
    @withdraws().reverse().slice(0,3)

window.Account = Account
