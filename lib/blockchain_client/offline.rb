# encoding: UTF-8
# frozen_string_literal: true

module BlockchainClient
  class Offline < Base

    def latest_block_number
      Rails.cache.read("latest_#{self.class.name.demodulize.underscore}_block_number")
    end
  end
end