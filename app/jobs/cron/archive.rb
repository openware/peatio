# frozen_string_literal: true

module Jobs
  module Cron
    class Archive
      def self.process
        # ORDER_MAX_AGE in minutes
        order_max_age = ENV.fetch('ORDER_MAX_AGE', 40320)

        # Cancel orders that older than max_order_age
        Order.where('created_at < ? AND state = ?', Time.now - order_max_age, 100).each do |o|
          Order.cancel(o.id)
        end

        yaml = ::Pathname.new("config/database.yml")
        return {} unless yaml.exist?

        config = ::SafeYAML.load(::ERB.new(yaml.read).result)['archive_production']

        return if config.blank?

        archive_database = Mysql2::Client.new(config)
        # TODO: Write orders to the archive database
        # time = Time.now
        # statement = ActiveRecord::Base.connection.raw_connection.prepare('SELECT * FROM `orders` WHERE updated_at < DATE_SUB(?, INTERVAL 1 WEEK) AND state = -100 AND trades_count = 0;')
        # result = statement.execute(time)
        # result = ActiveRecord::Base.connection.exec_query('SELECT * FROM `orders` WHERE updated_at < DATE_SUB(NOW(), INTERVAL 1 WEEK) AND state = -100 AND trades_count = 0;')
        # result.each do |record|
        #   record["uuid"] = UUID::Type.new.deserialize(record["uuid"])
        #   columns = record.keys.join(",")
        #   values = record.values.join(",")
        #   binding.pry
        #   archive_database.query("INSERT INTO orders (#{columns}) VALUES(#{values})")
        # end
        # Connection to the archive database

        # Delete old cancelled orders without trades
        ActiveRecord::Base.connection.exec_query('DELETE FROM `orders` WHERE updated_at < DATE_SUB(NOW(), INTERVAL 1 WEEK) AND state = -100 AND trades_count = 0;')

        # Execute sp.sql
        ActiveRecord::Base.connection.execute("call compact_liabilities('2020-07-28 00:00:00','2020-07-28 23:59:59')")
      end
    end
  end
end
