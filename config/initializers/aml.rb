# frozen_string_literal: true
require 'peatio/aml'

begin
  if ENV['AML_BACKEND'].present?
    Peatio::AML.adapter = "Peatio::AML::#{ENV.fetch('AML_BACKEND').capitalize}".constantize.new
  # else
  #   Peatio::AML.adapter = Peatio::AML::Dummy.new
  end
rescue StandardError
  # Peatio::AML.adapter = Peatio::AML::Dummy.new
end
