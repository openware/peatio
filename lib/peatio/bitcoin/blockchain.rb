module Bitcoin
  class Blockchain < Peatio::Blockchain::Abstract

    class MissingSettingError < StandardError
      def initialize(key = '')
        super "#{key.capitalize} setting is missing"
      end
    end

    DEFAULT_FEATURES = {case_sensitive: true, supports_cash_addr_format: false}.freeze

    def initialize(custom_features = {})
      @features = DEFAULT_FEATURES.merge(custom_features).slice(*SUPPORTED_FEATURES)
      @settings = {}
    end

    def configure(settings = {})
      @settings.merge!(settings.slice(*SUPPORTED_SETTINGS))
    end

    def fetch_block!(block_number)

    end

    def latest_block_number
      client.json_rpc(:getblockcount)
    end

    # @deprecated
    def case_sensitive?
      @features[:case_sensitive]
    end

    # @deprecated
    def supports_cash_addr_format?
      @features[:supports_cash_addr_format]
    end

    private

    def client
      @client ||= Bitcoin::Client.new(settings_fetch(:server))
    end

    def settings_fetch(key)
      @settings.fetch(key) { raise MissingSettingError(key.to_s) }
    end
  end
end
