# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Market
      class Positions < Grape::API
        helpers API::V2::NamedParams

        desc 'Returns User Futures Contract Positions.', scopes: %w(history),
             is_array: true,
             success: Entities::Position
        get '/positions' do
          positions = current_user.positions

          present positions, with: API::V2::Entities::Position, current_user: current_user
        end
      end
    end
  end
end
