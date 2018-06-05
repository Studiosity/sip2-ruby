$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'sip2'

require 'timecop'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.order = 'random'
end
