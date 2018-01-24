module Admin
  module Deposits
    class LitecoinController < ::Admin::Deposits::BaseController
      load_and_authorize_resource class: "::Deposits::Litecoin"

      def index
      end

      def update
      end
    end
  end
end
