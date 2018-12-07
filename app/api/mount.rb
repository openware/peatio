module API
  class Mount < Grape::API
    mount API::V2::Mount => '/v2'
  end
end