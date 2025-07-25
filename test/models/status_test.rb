require "test_helper"

class StatusTest < ActiveSupport::TestCase
  def setup
    @status = Status.new(value: "Test Status")
  end

  test "should be valid" do
    assert @status.valid?
  end

  test "value should be present" do
    @status.value = nil
    assert_not @status.valid?
  end

  test "value should be unique" do
    @status.save
    duplicate_status = Status.new(value: "Test Status")
    assert_not duplicate_status.valid?
  end

  test "should generate color on save" do
    @status.save
    assert_not_nil @status.color
    assert @status.color.start_with?("#")
    assert_equal 7, @status.color.length
  end
end
