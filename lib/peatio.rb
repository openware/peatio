module Peatio
  class << self
    def base_fiat_ccy
      ENV.fetch('BASE_FIAT_CCY').upcase
    end

    def base_fiat_ccy_sym
      base_fiat_ccy.to_sym
    end
  end
end
