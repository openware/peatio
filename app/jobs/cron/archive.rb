# frozen_string_literal: true

module Jobs
  module Cron
    class Archive
      def self.process
        start_time = Time.now.beginning_of_day + 2.hours
        if @last_archive_time.present?
          unless Time.now > start_time && @last_archive_time > Time.now - 24.hours
            return
          end
        end

        # ORDER_MAX_AGE in minutes
        order_max_age = ENV.fetch('ORDER_MAX_AGE', 40_320)

        # Cancel orders that older than max_order_age
        Order.where('created_at < ? AND state = ?', Time.now - order_max_age, 100).each do |o|
          Order.cancel(o.id)
        end

        config = db_archive_config
        return if config.blank?

        result = ActiveRecord::Base.connection.exec_query('SELECT * FROM `orders` WHERE updated_at < DATE_SUB(NOW(), INTERVAL 1 WEEK) AND state = -100 AND trades_count = 0;')
        # Connection to the archive database
        ActiveRecord::Base.establish_connection(:archive_db)
        # Copy old cancelled orders without trades to the archive database
        result.each do |order|
          ActiveRecord::Base.connection.exec_query(order_query(order))
        end

        # Connection to the main database
        ActiveRecord::Base.establish_connection(ENV['RAILS_ENV'].to_sym)

        # Delete old cancelled orders without trades
        ActiveRecord::Base.connection.exec_query('DELETE FROM `orders` WHERE updated_at < DATE_SUB(NOW(), INTERVAL 1 WEEK) AND state = -100 AND trades_count = 0;')

        # Execute Stored Procedure for Liabilities compacting
        ActiveRecord::Base.connection.execute("call compact_liabilities('2020-07-28 00:00:00','2020-07-28 23:59:59')")
        sleep 360
      end

      def self.db_archive_config
        yaml = ::Pathname.new('config/database.yml')
        return {} unless yaml.exist?

        ::SafeYAML.load(::ERB.new(yaml.read).result)['archive_db']
      end

      def self.order_query(order)
        order['remote_id'] = order['remote_id'].nil? ? 'NULL' : order['remote_id']
        order['uuid'] = UUID::Type.new.quoted_id(order['uuid'])
        'INSERT INTO orders (id, uuid, remote_id, bid, ask, market_id, price, ' \
        'volume, origin_volume, maker_fee, taker_fee, state, type, member_id, ord_type, ' \
        'locked, origin_locked, funds_received, trades_count, created_at, updated_at) ' \
        "VALUES(#{order['id']}, #{order['uuid']}, #{order['remote_id']},  " \
        "'#{order['bid']}', '#{order['ask']}', '#{order['market_id']}', " \
        "#{order['price']}, #{order['volume']}, #{order['origin_volume']}, " \
        "#{order['maker_fee']}, #{order['taker_fee']}, #{order['state']}, " \
        "'#{order['type']}', #{order['member_id']}, '#{order['ord_type']}', " \
        "#{order['locked']}, #{order['origin_locked']}, #{order['funds_received']}, " \
        "#{order['trades_count']}, '#{order['created_at']}', '#{order['updated_at']}')"
      end
    end
  end
end
