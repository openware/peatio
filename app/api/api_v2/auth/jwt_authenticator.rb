# encoding: UTF-8
# frozen_string_literal: true

require 'authorization/bearer'

module APIv2
  module Auth
    class JWTAuthenticator
      include Authorization::Bearer

      def initialize(token)
        @token = token
      end

      #
      # Decodes and verifies JWT.
      # Returns authentic member email or raises an exception.
      #
      # @param [Hash] options
      # @return [String, Member, NilClass]
      def authenticate
        payload, header = authenticate!(@token)
        fetch_email(payload)
      rescue => e
        report_exception(e)
        if Peatio::Auth::Error === e
          raise e
        else
          raise Peatio::Auth::Error, e.inspect
        end
      end

    private
      def fetch_email(payload)
        payload[:email].to_s.tap do |email|
          raise(Peatio::Auth::Error, 'E-Mail is blank.') if email.blank?
          raise(Peatio::Auth::Error, 'E-Mail is invalid.') unless EmailValidator.valid?(email)
        end
      end

      def fetch_member(payload)
        begin
          Member::from_payload(payload)
        # Handle race conditions when creating member & authentication records.
        # We do not handle race condition for update operations.
        # http://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-find_or_create_by
        rescue ActiveRecord::RecordNotUnique
          retry
        end
      end
    end
  end
end
