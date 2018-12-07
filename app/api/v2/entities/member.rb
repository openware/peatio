# encoding: UTF-8
# frozen_string_literal: true

module V2
  module Entities
    class Member < Base
      expose :uid
      expose :email
      expose(:accounts, using: ::V2::Entities::Account) do |m|
        m.accounts.enabled.includes(:currency)
      end
    end
  end
end
