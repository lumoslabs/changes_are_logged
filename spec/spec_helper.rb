require 'rubygems'
require 'bundler/setup'
require 'active_record'

require 'changes_are_logged'

require 'support/database_helpers' #test_data'

RSpec.configure do |config|
  config.include ChangesAreLogged::Spec::DatabaseHelpers

  config.before do
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
    setup_db
  end

  config.after do
    teardown_db
  end
end