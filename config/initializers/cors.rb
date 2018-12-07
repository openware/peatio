require 'grape/middleware/error'

module APIv2
  module CORS
    def rack_response(*args)
      if env.fetch('REQUEST_URI').match?(/\A\/api\/v2\//)
        args << {} if args.count < 3
        API::V2::CORS.call(args[2])
      end
      super(*args)
    end
  end
end

Grape::Middleware::Error.prepend APIv2::CORS
