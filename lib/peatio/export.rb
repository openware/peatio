# frozen_string_literal: true

module Peatio
  class Export
    def initialize; end

    def export(model_name)
      model_name.constantize.all.map do |m|
        m.attributes.except('settings_encrypted', 'data_encrypted', 'created_at',
                            'updated_at', 'key', 'secret')
         .merge('settings' => m.try(:settings),
                'data' => m.try(:data),
                'key' => m.try(:key),
                'secret' => m.try(:secret),
                'currency_ids' => m.try(:currency_ids))
      end.map { |r| r.transform_values! { |v| v.is_a?(BigDecimal) ? v.to_f : v } }.map(&:compact)
    end

    def export_blockchains
      export('Blockchain').map { |r| r.except('id', 'currency_ids') }
    end

    def export_currencies
      export('Currency').map { |c| c['options'] = c['options'].to_h; c }
    end

    def export_markets
      export('Market')
    end

    def export_wallets
      export('Wallet').map { |r| r.except('id') }
    end

    def export_trading_fees
      export('TradingFee').map { |r| r.except('id') }
    end

    def export_engines
      export('Engine')
    end
  end
end
