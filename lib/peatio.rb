module Peatio
  class << self
    def base_fiat_ccy
      unless Currency.exists?
        ActiveRecord::Tasks::DatabaseTasks.load_seed
      end

      return Currency.find_by(code: 'usd').code if Currency.exists?(code: 'usd')
      raise 'seed.rb should create base fiat currency'
    end

    def base_fiat_ccy_sym
      base_fiat_ccy.to_sym
    end
  end
end
