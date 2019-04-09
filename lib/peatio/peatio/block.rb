module Peatio
  class Block
    include Enumerable

    delegate :each, to: :@transactions

    attr_reader :number, :transactions

    def initialize(number, transactions)
      @number = number
      @transactions = transactions
    end
  end
end
