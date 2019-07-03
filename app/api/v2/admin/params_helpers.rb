# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module ParamsHelpers

        def time_param(param)
          param.present? ? Time.at(param) : nil
        end
      end
    end
  end
end
