require 'rubygems'
require "../../../config/boot.rb" if File.exist?("../../../config/boot.rb")

$KCODE = 'u' if RUBY_VERSION < '1.9' # as per railties initializer.rb: set unicode mode for Ruby 1.8 (Ruby 1.9 just works)

require 'test/unit'
require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'active_record/fixtures'

begin
  require 'ruby-debug'
  Debugger.start
rescue LoadError
  # ruby-debug not installed, no debugging for you
end

ENV['RAILS_ENV'] ||= 'test'
FileUtils.mkdir File.join(File.dirname(__FILE__), "log") rescue nil
RAILS_DEFAULT_LOGGER = ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), "log", "#{ENV['RAILS_ENV']}.log"))

ActiveRecord::Base.configurations = YAML::load(IO.read(File.join(File.dirname(__FILE__), "database.yml")))
ActiveRecord::Base.establish_connection ActiveRecord::Base.configurations[ENV['RAILS_ENV']]
ActiveSupport::TestCase.send(:include, ActiveRecord::TestFixtures) if ActiveRecord.const_defined?('TestFixtures')
ActiveSupport::TestCase.fixture_path = File.join(File.dirname(__FILE__), "fixtures")

require File.expand_path(File.join(File.dirname(__FILE__), '../init')) # load table_display
