# encoding: UTF-8
# frozen_string_literal: true

module Public
  class HealthController < ActionController::Base
    before_action :no_cache

    def liveness_probe
      #check db
      #check redis
      #check rabbit
      #check smtp_relay
      #check daemons
      return head 200
    rescue Exception => e
      Rails.logger.error { "liveness_probe: #{e.inspect}" }
      head 500
    end

    def readiness_probe
      db_seeded = Currency.exists? && Market.exists?
      head db_seeded ? 200 : 500
    rescue Exception => e
      Rails.logger.error { "readiness_probe: #{e.inspect}" }
      head 500
    end

    private

    def no_cache
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Sat, 03 Jan 2009 00:00:00 GMT"
    end
  end
end
