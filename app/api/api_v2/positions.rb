# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  class Positions < Grape::API
    helpers ::APIv2::NamedParams
    before { authenticate! }

    desc 'Returns User Futures Contract Positions.',
         is_array: true,
         success: Entities::Position
    get '/future_positions' do
      positions = current_user.positions

      present positions, with: APIv2::Entities::Position
    end
  end
end
