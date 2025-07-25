require "test_helper"

class LocationTest < ActiveSupport::TestCase
  def setup
    @location = Location.new(value: "Test Location")
  end

  test "should be valid" do
    assert @location.valid?
  end

  test "value should be present" do
    @location.value = nil
    assert_not @location.valid?
  end

  test "value should be unique" do
    @location.save
    duplicate_location = Location.new(value: "Test Location")
    assert_not duplicate_location.valid?
  end

  test "should generate color on save" do
    @location.save
    assert_not_nil @location.color
    assert @location.color.start_with?("#")
    assert_equal 7, @location.color.length
  end
end
