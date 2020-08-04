# frozen_string_literal: true

class Job < ApplicationRecord
  def self.execute(name)
    job = new(name: name, started_at: Time.now)
    result = yield
    binding.pry
  end
end
