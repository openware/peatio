# frozen_string_literal: true
require 'peatio/aml'

begin
  if ENV['AML_BACKEND'].present?
    Peatio::AML.adapter = "Peatio::AML::#{ENV.fetch('AML_BACKEND').capitalize}".constantize.new
  end
rescue StandardError => e
  Rails.logger.error { e.message }
end
