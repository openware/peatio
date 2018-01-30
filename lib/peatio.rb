module Peatio
  class << self
    def base_fiat_ccy
      ENV['BASE_FIAT_CCY']
    end
  end
end
