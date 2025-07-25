require "test_helper"

class BtOptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bt_option = bt_options(:one)
  end

  test "should get index" do
    get bt_options_url
    assert_response :success
  end

  test "should get new" do
    get new_bt_option_url
    assert_response :success
  end

  test "should create bt_option" do
    assert_difference("BtOption.count") do
      post bt_options_url, params: { bt_option: { value: 123 } }
    end

    assert_redirected_to bt_option_url(BtOption.last)
  end

  test "should show bt_option" do
    get bt_option_url(@bt_option)
    assert_response :success
  end

  test "should get edit" do
    get edit_bt_option_url(@bt_option)
    assert_response :success
  end

  test "should update bt_option" do
    patch bt_option_url(@bt_option), params: { bt_option: { value: 456 } }
    assert_redirected_to bt_option_url(@bt_option)
  end

  test "should destroy bt_option" do
    assert_difference("BtOption.count", -1) do
      delete bt_option_url(@bt_option)
    end

    assert_redirected_to bt_options_url
  end
end
