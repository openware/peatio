# encoding: UTF-8
# frozen_string_literal: true

# Crontab to run rake task every month at 1am
# Use command crontab -e to edit crontab and add following command
# 0 1 1 * * /bin/bash -l -c 'cd ~/peatio && RAILS_ENV=production bundle exec rake archive:seed --silent'

namespace :archive do
  desc 'Archive order and trade tables.'
  task seed: :environment do
    Services::Archive.new.call
  end
end


