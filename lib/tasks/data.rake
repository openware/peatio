namespace :data do
  task feed: :environment do
    feeder = MemberFeeder.new
    10.times do
      member = feeder.feed
    end

    admin_feeder = AdminFeeder.new
    admin = admin_feeder.feed

    Rails.logger.info 'Database feed finished!'
  end
end
