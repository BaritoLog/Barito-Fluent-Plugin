require "helper"
require "fluent/plugin/out_barito.rb"

class BaritoOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::BaritoOutput).configure(conf)
  end
end
