require 'simplecov'
SimpleCov.start 'rails'
SimpleCov.command_name "MiniTest"

Rails.env ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/rails"
require "minitest/rails/capybara"

include Devise::TestHelpers

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!
  fixtures :all
end

def sign_in_capybara(login = users(:sam).email, password = "password", fail_sign_in = false)
  fill_in "Login", with: login
  fill_in "Password", with: password
  click_on "Submit"
  # page.must_have_content I18n.t("devise.sessions.signed_in") unless fail_sign_in
end

def setup_omniauth_for_testing
  visit root_path
  OmniAuth.config.test_mode = true
  Capybara.current_session.driver.request.env['devise.mapping'] = Devise.mappings[:user]
end

def seed_db
  User.create(username: "Zoobit Shelter", email: "shelter@zoobit.net", id: 1, password: "zoobit123", created_at: Time.now, last_sign_in_at: Time.now)
  User.create(username: "Admin", email: "admin@zoobit.net", id: 2, password: "zoobit123", created_at: Time.now, last_sign_in_at: Time.now)
end
