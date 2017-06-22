source 'https://rubygems.org'

gem 'rails',           '5.0.0.1'
gem 'rdoc'
gem 'carrierwave'
gem 'figaro'
gem 'bcrypt'
gem 'redis'

gem 'mail'
gem "actionmailer"

gem 'config'

# the special version of sidekiq might be because of Mac OS - the package manager version always had a dependency problem
gem 'sidekiq', github: 'mperham/sidekiq'
# sinatra is needed for the sidekiq web interface
gem 'sinatra', github: 'sinatra/sinatra'

gem 'bootstrap-sass',  '3.3.7'
gem 'bootstrap-social-rails'
gem 'font-awesome-rails'
gem 'puma',            '3.4.0'
gem 'sass-rails',      '5.0.6'
gem 'uglifier',        '3.0.0'
gem 'coffee-rails',    '4.2.1'
gem 'jquery-rails',    '4.1.1'
gem 'turbolinks',      '5.0.1'
gem 'jbuilder',        '2.4.1'
gem 'openstack', :github => 'ruby-openstack/ruby-openstack', :branch => 'master'

gem 'rest-client', '~> 1.8'

group :development, :test do
  gem 'sqlite3', '1.3.11'
  gem 'byebug',  '9.0.0', platform: :mri
end

group :development do
  gem 'web-console',           '3.1.1'
  gem 'listen',                '3.0.8'
  gem 'spring',                '1.7.2'
  gem 'spring-watcher-listen', '2.0.0'
  # gem "ruby-debug-base"
  # gem "ruby-debug-ide"
end

group :test do
  gem 'webmock'
  gem 'rails-controller-testing', '0.1.1'
  gem 'minitest-reporters',       '1.1.9'
  gem 'guard',                    '2.13.0'
  gem 'guard-minitest',           '2.4.4'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
