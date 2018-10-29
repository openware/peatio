# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  module Auth
    class JWTAuthenticator
      def initialize(token)
        @token = token
      end

      #
      # Decodes and verifies JWT.
      # Returns authentic member email or raises an exception.
      #
      # @param [Hash] options
      # @return [String, Member, NilClass]
      def authenticate!(options = {})
        payload, header = Peatio::Auth::JWTAuthenticator
                              .new(Utils.jwt_public_key)
                              .authenticate!(@token)
        fetch_member(payload).yield_self do |member|
          options[:return] == :member ? member : fetch_email(payload)
        end
      rescue => e
        report_exception(e)
        if Peatio::Auth::Error === e
          raise e
        else
          raise Peatio::Auth::Error, e.inspect
        end
      end

      #
      # Exception-safe version of #authenticate!.
      #
      # @return [String, Member, NilClass]
      def authenticate(*args)
        authenticate!(*args)
      rescue
        nil
      end

    private
      def fetch_email(payload)
        payload[:email].to_s.tap do |email|
          raise(Peatio::Auth::Error, 'E-Mail is blank.') if email.blank?
          raise(Peatio::Auth::Error, 'E-Mail is invalid.') unless EmailValidator.valid?(email)
        end
      end

      def fetch_uid(payload)
        payload.fetch(:uid).tap { |uid| raise(Peatio::Auth::Error, 'UID is blank.') if uid.blank? }
      end

      def fetch_scopes(payload)
        Array.wrap(payload[:scopes]).map(&:to_s).map(&:squash).reject(&:blank).tap do |scopes|
          raise(Peatio::Auth::Error, 'Token scopes are not defined.') if scopes.empty?
        end
      end

      def fetch_member(payload)
        if payload[:iss] == 'barong'
          begin
            from_barong_payload(payload)
          # Handle race conditions when creating member & authentication records.
          # We do not handle race condition for update operations.
          # http://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-find_or_create_by
          rescue ActiveRecord::RecordNotUnique
            retry
          end
        else
          Member.find_by_email(fetch_email(payload))
        end
      end

      def from_barong_payload(payload)
        Member.from_payload(payload)
      end
    end
  end
end
