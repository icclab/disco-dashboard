ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def is_logged_in?
    !cookies['user_id'].empty?
  end
end

class ActionDispatch::IntegrationTest

  def login_as(user, password: "password")
    post login_url, params: { sessison: { email:    user.email,
                                          password: password    } }
  end
end
