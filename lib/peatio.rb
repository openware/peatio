module Peatio
  class << self
    def base_fiat_ccy
      unless Currency.exists?
        Rake::Task['currencies:seed'].invoke
      end

      Currency.find_by(code: 'usd').code if Currency.exists?(code: 'usd')
    end

    def base_fiat_ccy_sym
      base_fiat_ccy.to_sym
    end
  end
end
