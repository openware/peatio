# encoding: UTF-8
# frozen_string_literal: true

module Worker
  class MemberCreate
    def process(payload)
      foreign_id = payload["foreign_id"]
      email = payload["email"]

      unless email && foreign_id
        Rails.logger.warn { "Received invalid create_member message: #{payload}" }
        return
      end

      member = Member.new(email: email)

      if member.save
        Member.trigger_pusher_event(member, :member_create, {
          email: email,
          foreign_id: foreign_id,
        })

        member.accounts.each { |account| account.payment_address }
      else
        Member.trigger_pusher_event(nil, :member_create_error, {
          foreign_id: foreign_id,
          errors: member.errors.messages
        })
      end
    end
  end
end
