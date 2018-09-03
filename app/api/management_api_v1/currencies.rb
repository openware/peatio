# encoding: UTF-8
# frozen_string_literal: true

module ManagementAPIv1
  class Currencies < Grape::API

    desc 'Return currency by id' do
      @settings[:scope] = :read_currencies
      success ManagementAPIv1::Entities::Currency
    end
    params do
      requires :id, type: String, desc: "Currency code"
    end
    post '/currency/get' do
      present Currency.find_by!(id: params[:id]), with: ManagementAPIv1::Entities::Currency
      status 200
    end

    desc 'Return all currencies' do
      @settings[:scope] = :read_currencies
      success ManagementAPIv1::Entities::Currency
    end
    post '/currencies' do
      present Currency.all, with: ManagementAPIv1::Entities::Currency
      status 200
    end

    desc 'Update currency' do
      @settings[:scope] = :write_currencies
      success ManagementAPIv1::Entities::Currency
    end
    params do
      requires :id, type: String, desc: "Currency code"
      optional :blockchain_key, values: -> { Blockchain.pluck(:key) }, type: String, desc: 'Currency blockchain key'
      optional :symbol, type: String, desc: 'Currency symbol'
      optional :deposit_fee, type: BigDecimal, desc: 'Currency deposit fee'
      optional :quick_withdraw_limit, type: BigDecimal, desc: 'Currency quick withdraw limit'
      optional :withdraw_fee, type: BigDecimal, desc: 'Currency withdraw fee'
      optional :base_factor, type: Integer, desc: 'Currency base factor'
      optional :precision, type: Integer, desc: 'Currency precision'
      optional :icon_url, type: String, desc: 'Currency icon url'
      optional :enabled, type: Boolean, desc: 'Currency status'
      optional :supports_hd_protocol, type: Boolean
      optional :allow_multiple_deposit_addresses, type: Boolean
    end
    put '/currency/update' do
      currency = Currency.find_by!(id: params[:id])
      if currency.update(params)
        present currency, with: ManagementAPIv1::Entities::Currency
        status 200
      else
        body errors: currency.errors.full_messages
        status 422
      end
    end

    desc 'Create currency' do
      @settings[:scope] = :write_currencies
      success ManagementAPIv1::Entities::Currency
    end
    params do
      requires :id, type: String, desc: 'Currency code'
      requires :blockchain_key, values: -> { Blockchain.pluck(:key) }, type: String, desc: 'Currency blockchain key'
      requires :symbol, type: String, desc: 'Currency symbol'
      requires :type, type: String, desc: 'Currency type'
      requires :deposit_fee, type: BigDecimal, desc: 'Currency deposit fee'
      requires :quick_withdraw_limit, type: BigDecimal, desc: 'Currency quick withdraw limit'
      requires :withdraw_fee, type: BigDecimal, desc: 'Currency withdraw fee'
      requires :base_factor, type: Integer, desc: 'Currency base factor'
      requires :precision, type: Integer, desc: 'Currency precision'
      optional :enabled, type: Boolean, desc: 'Currency status'
      optional :icon_url, type: String, desc: 'Currency icon url'
      optional :supports_hd_protocol, type: Boolean
      optional :allow_multiple_deposit_addresses, type: Boolean
    end
    post '/currency/new' do
      currency = Currency.new(params)
      if currency.save
        present currency, with: ManagementAPIv1::Entities::Currency
        status 201
      else
        body errors: currency.errors.full_messages
        status 422
      end
    end
  end
end
