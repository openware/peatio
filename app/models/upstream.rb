# frozen_string_literal: true

class Upstream < ActiveRecord::Base
  has_many :markets

  scope :enabled, -> { where(enabled: true) }

  validates :timeout, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :provider, presence: true

  cattr_reader :services

  def service
    @@services = {} if services.nil?
    return services[provider] if services[provider].present?

    service_class = "Peatio::Upstream::#{provider.titleize}".constantize
    @@services[provider] = service_class.new
  end
end

# == Schema Information
# Schema version: 20180905093248
#
# Table name: upstreams
#
#  id         :integer          not null, primary key
#  provider   :string(32)       not null
#  enabled    :boolean          default(FALSE), not null
#  api_secret :string(255)
#  api_key    :string(255)
#  timeout    :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_upstreams_on_provider  (provider) UNIQUE
#
