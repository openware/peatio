# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'member'

class Member
  module Levels
    class << self
      def get(data)
        if Numeric === data
          from_numerical_barong_level(data)
        else
          data.presence
        end
      end

      def from_numerical_barong_level(num)
        num >= ENV.fetch('MINIMUM_LEVEL', 3).to_i ? :kyc_verified : :unverified
      end
    end
  end
end
