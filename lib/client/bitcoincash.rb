# encoding: UTF-8
# frozen_string_literal: true

module Client
  class Bitcoincash < Bitcoin
    def normalize_address(address)
      CashAddr::Converter.to_legacy_address(super)
    end
  end
end
