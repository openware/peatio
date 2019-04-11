# encoding: UTF-8
# frozen_string_literal: true

FakeBlockchain = Class.new(Peatio::Blockchain::Abstract)
Peatio::BlockchainAPI.register(:fake, FakeBlockchain)

describe BlockchainService2 do
  # TODO: Create blockchain with fake client.
  # TODO: Create 2 currencies for blockchain with fake client.
  # Deposit context: (mock fetch_block)
  #   * Single deposit in block which should be saved.
  #   * Multiple deposits in single block (one saved one updated).
  #   * Multiple deposits for 2 currencies in single block.
  #   * Multiple deposits in single transaction (different txout).
  #
  # Withdraw context: (mock fetch_block)
  #   * Single withdrawal.
  #   * Multiple withdrawals for single currency.
  #   * Multiple withdrawals for 2 currencies.
end
