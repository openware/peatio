# encoding: UTF-8
# frozen_string_literal: true

module ManagementAPIv1
  class Markets < Grape::API
    desc 'Returns all markets.' do
      @settings[:scope] = :read_markets
      success ManagementAPIv1::Entities::Market
    end
    post '/markets' do
      present Market.all, with: ManagementAPIv1::Entities::Market
      status 200
    end

    desc 'Returns market by id' do
      @settings[:scope] = :read_markets
      success ManagementAPIv1::Entities::Market
    end
    params do
      requires :id, type: String, desc: 'Market id'
    end
    post '/markets/get' do
      present Market.find_by!(id: params[:id]), with: ManagementAPIv1::Entities::Market
      status 200
    end

    desc 'Creates new market' do
      @settings[:scope] = :write_markets
      success ManagementAPIv1::Entities::Market
    end
    params do
      requires :ask_unit, type: String, values: -> { Currency.codes(bothcase: true) }, desc: 'Market ask unit'
      requires :bid_unit, type: String, values: -> { Currency.codes(bothcase: true) }, desc: 'Market bid unit'
      requires :ask_fee, type: BigDecimal, desc: 'Market ask fee'
      requires :bid_fee, type: BigDecimal, desc: 'Market bid fee'
      optional :max_bid, type: BigDecimal, desc: 'Market max bid'
      optional :min_ask, type: BigDecimal, default: 0, desc: 'Market min ask'
      requires :ask_precision, type: Integer, integer_gt_zero: true, desc: 'Market ask precision'
      requires :bid_precision, type: Integer, integer_gt_zero: true, desc: 'Market bid precision'
      optional :position, type: Integer, integer_gt_zero: true, desc: 'Market position'
      optional :enabled, type: Boolean, default: true, desc: 'Market status'
    end
    post '/markets/new' do
      market = Market.new(params)
      if market.save
        present market, with: ManagementAPIv1::Entities::Market
        status 201
      else
        body errors: market.errors.full_messages
        status 422
      end
    end

    desc 'Updates exist market' do
      @settings[:scope] = :write_markets
      success ManagementAPIv1::Entities::Market
    end
    params do
      requires :id, type: String, desc: 'Market id.'
      optional :ask_fee, type: BigDecimal, desc: 'Market ask fee'
      optional :bid_fee, type: BigDecimal, desc: 'Market bid fee'
      optional :max_bid, type: BigDecimal, desc: 'Market max bid'
      optional :min_ask, type: BigDecimal, default: 0, desc: 'Market min ask'
      optional :position, type: Integer, integer_gt_zero: true, desc: 'Market position'
      optional :enabled, type: Boolean, desc: 'Market status'
    end
    put '/markets/update' do
      market = Market.find_by!(id: params[:id])
      if market.update(params)
        present market, with: ManagementAPIv1::Entities::Market
        status 200
      else
        body errors: market.errors.full_messages
        status 422
      end
    end
  end
end
