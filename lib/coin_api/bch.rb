module CoinAPI
  class BCH < BTC
    def normalize_address(address)
      CashAddr::Converter.to_legacy_address(address).downcase
    end
  end
end
