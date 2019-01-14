# encoding: UTF-8
# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) {|repo_slug| "https://github.com/#{repo_slug}"}

gem 'rails', '~> 5.2', '>= 5.2.2'
gem 'rails-i18n', '~> 5.1.2'
gem 'puma', '~> 3.12.0'
gem 'mysql2', '~> 0.5.2'
gem 'redis-rails', '~> 5.0.2'
gem 'jbuilder', '~> 2.8.0'
gem 'figaro', '~> 1.1.1'
gem 'hashie', '~> 3.6.0'
gem 'aasm', '~> 5.0.1'
gem 'bunny', '~> 2.13.0'
gem 'cancancan', '~> 2.3.0'
gem 'enumerize', '~> 2.2.2'
gem 'kaminari', '~> 1.1.1'
gem 'gon', '~> 6.2.1'
gem 'sassc-rails', '~> 2.1.0'
gem 'coffee-rails', '~> 4.2.2'
gem 'uglifier', '~> 4.1.20'
gem 'jquery-rails', '~> 4.3.3'
gem 'angularjs-rails', '~> 1.6.8'
gem 'bootstrap', '~> 4.2.1'
gem 'font-awesome-sass', '~> 5.6.1'
gem 'rbtree', '~> 0.4.2'
gem 'grape', '~> 1.2.2'
gem 'grape-entity', '~> 0.7.1'
gem 'grape-swagger', '~> 0.32.1'
gem 'grape-swagger-ui', '~> 2.2.8'
gem 'grape-swagger-entity', '~> 0.3.1'
gem 'grape_strip', '~> 1.0.1'
gem 'grape_logging', '~> 1.8.0'
gem 'rack-attack', '~> 5.4.2'
gem 'easy_table', '~> 0.0.10'
gem 'faraday', '~> 0.15.4'
gem 'jwt', '~> 2.1.0'
gem 'email_validator', '~> 1.6.0'
gem 'validate_url', '~> 1.0.2'
gem 'clipboard-rails', '~> 1.7.1'
gem 'god', '~> 0.13.7', require: false
gem 'mini_racer', '~> 0.2.4', require: false
gem 'arel-is-blank', '~> 1.0.0'
gem 'sentry-raven', '~> 2.8.0', require: false
gem 'memoist', '~> 0.16.0'
gem 'method-not-implemented', '~> 1.0.1'
gem 'passgen', '~> 1.0.2'
gem 'validates_lengths_from_database', '~> 0.7.0'
gem 'jwt-multisig', '~> 1.0.0'
gem 'cash-addr', '~> 0.2.0', require: 'cash_addr'
gem 'digest-sha3', '~> 1.1.0'
gem 'scout_apm', '~> 2.4.21', require: false
gem 'peatio', '~> 0.4.4'
gem 'rack-cors', '~> 1.0.2', require: false
gem 'env-tweaks', '~> 1.0.0', require: false
gem 'bootsnap', '~> 1.3.2', require: false
gem 'tzinfo-data', '~> 1.2.5', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :development, :test do
  gem 'bump', '~> 0.7'
  gem 'faker', '~> 1.9.1'
  gem 'pry-byebug', '~> 3.6'
  gem 'bullet', '~> 5.9.0'
  gem 'grape_on_rails_routes', '~> 0.3.2'
end

group :development do
  gem 'annotate', '~> 2.7.4'
  gem 'ruby-prof', '~> 0.17.0', require: false
  gem 'spring', '~> 2.0.2'
  gem 'spring-watcher-listen', '~> 2.0.1'
end

group :test do
  gem 'rspec-rails', '~> 3.8.1'
  gem 'rspec-retry', '~> 0.6.1'
  gem 'webmock', '~> 3.5.1'
  gem 'database_cleaner', '~> 1.7.0'
  gem 'mocha', '~> 1.7.0', require: false
  gem 'factory_bot_rails', '~> 4.11.1'
  gem 'timecop', '~> 0.9.1'
  gem 'rubocop-rspec', '~> 1.31.0', require: false
  gem 'rails-controller-testing', '~> 1.0.4'
end

# Load gems from Gemfile.plugin.
Dir.glob File.expand_path('../Gemfile.plugin', __FILE__) do |file|
  eval_gemfile file
end
