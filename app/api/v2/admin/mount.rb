# frozen_string_literal: true

module API
  module V2
    module Admin
      class Mount < Grape::API

        before { authenticate! }

        mount Admin::Orders
        mount Admin::Blockchains
        mount Admin::Currencies
      end
    end
  end
end