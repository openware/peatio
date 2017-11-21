module Auth0
  class PeatioAPITokenAdapter
    extend Memoist

    def initialize(jwt, jwt_payload)
      @jwt         = jwt
      @jwt_payload = jwt_payload
      @user        = Auth0::ManagementAPI::Client.new.user(jwt_payload.fetch('sub'))
    end

    def member
      email = @user.fetch('email')
      Member.find_by_email(email) || Member.create!(
        email:     email,
        nickname:  @user.fetch('nickname'),
        activated: true
      )
    end
    memoize :member

    def access_key
      @jwt
    end

    def allow_ip?(*)
      true
    end
  end
end
