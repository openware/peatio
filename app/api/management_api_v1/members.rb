# encoding: UTF-8
# frozen_string_literal: true

module ManagementAPIv1
  class Members < Grape::API

    helpers do
      def fetch_email(payload)
        payload[:email].to_s.tap do |email|
          error!('AuthorizationError: E-Mail is blank.') if email.blank?
          error!('AuthorizationError: E-Mail is invalid.') unless EmailValidator.valid?(email)
        end
      end

      def fetch_uid(payload)
        payload.fetch(:uid).tap { |uid| error!('AuthorizationError: UID is blank.') if uid.blank? }
      end
    end

    desc 'Create new member.' do
      @settings[:scope] = :write_members
    end

    params do
      requires :email, type: String,  desc: 'The shared user email.'
      requires :level, type: Integer, desc: 'Level of user.'
      requires :uid,   type: String,  desc: 'The shared user ID.'
      requires :state, type: String,  desc: 'The shared state of user.'
    end

    post '/create/member' do
      Member.find_or_initialize_by(email: fetch_email(params)).tap do |member|
        member.transaction do
          attributes = {
            level:    params[:level],
            disabled: params[:state] != 'active'
          }

          # Prevent overheat validations.
          member.assign_attributes(attributes)
          member.save!(validate: member.new_record?)

          member.touch_accounts

          authentication = member.authentications.find_or_initialize_by(provider: 'barong', uid: fetch_uid(params))

          # Prevent overheat validations.
          authentication.save! if authentication.new_record?
          if member && authentication
            body message: 'Member was created successfully'
            status 200
          else
            body errors: member.errors.full_messages || authentication.errors.full_messages
            status 422
          end
        end
      end
    end
  end
end
