namespace :markets do
  desc 'Adds missing markets to database defined at config/seed/markets.yml.'
  task seed: :environment do
    Market.transaction do
      seed_yml = Rails.root.join('config/seed/markets.yml')
      if File.file?(seed_yml)
        YAML.load_file(seed_yml).each do |hash|
          next if Market.exists?(id: hash.fetch('id'))
          Market.create!(hash)
        end
      end
    end
  end
end
