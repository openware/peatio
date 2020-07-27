# encoding: UTF-8
# frozen_string_literal: true

require "active_support/core_ext/object/blank"

module ENVTweaks
  module Extension
    def true?(var)
      !false?(var)
    end

    def false?(var)
      self[var].blank? || %w[false 0 nil null].include?(self[var])
    end
  end
end

ENV.extend ENVTweaks::Extension