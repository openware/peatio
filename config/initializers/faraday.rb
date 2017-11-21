class Faraday::Response
  def assert_ok!
    raise Faraday::Error, "Received HTTP #{status}." unless status == 200
    self
  end
end
