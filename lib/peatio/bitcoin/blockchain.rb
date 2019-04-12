module Bitcoin
  class Blockchain < Peatio::Blockchain::Abstract

    class MissingSettingError < StandardError
      def initialize(key = '')
        super "#{key.capitalize} setting is missing"
      end
    end

    DEFAULT_SETTINGS = {case_sensitive: true, supports_cash_addr_format: false}.freeze

    def initialize(settings = {})
      @settings = settings.slice(:case_sensitive, :supports_cash_addr_format)
                    .reverse_merge(DEFAULT_SETTINGS)
    end

    def configure(settings = {})
      @settings.merge!(settings.slice(:server, :currencies))
    end

    def fetch_block!(block_number)

    end

    def latest_block_number

    end

    def case_sensitive?
      settings_fetch(:case_sensitive)
    end

    def supports_cash_addr_format?
      settings_fetch(:supports_cash_addr_format)
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
