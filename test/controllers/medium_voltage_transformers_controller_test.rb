require "test_helper"

class MediumVoltageTransformersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @medium_voltage_transformer = medium_voltage_transformers(:one)
  end

  test "should get index" do
    get medium_voltage_transformers_url
    assert_response :success
  end

  test "should get new" do
    get new_medium_voltage_transformer_url
    assert_response :success
  end

  test "should create medium_voltage_transformer" do
    assert_difference("MediumVoltageTransformer.count") do
      post medium_voltage_transformers_url, params: { medium_voltage_transformer: {} }
    end

    assert_redirected_to medium_voltage_transformer_url(MediumVoltageTransformer.last)
  end

  test "should show medium_voltage_transformer" do
    get medium_voltage_transformer_url(@medium_voltage_transformer)
    assert_response :success
  end

  test "should get edit" do
    get edit_medium_voltage_transformer_url(@medium_voltage_transformer)
    assert_response :success
  end

  test "should update medium_voltage_transformer" do
    patch medium_voltage_transformer_url(@medium_voltage_transformer), params: { medium_voltage_transformer: {} }
    assert_redirected_to medium_voltage_transformer_url(@medium_voltage_transformer)
  end

  test "should destroy medium_voltage_transformer" do
    assert_difference("MediumVoltageTransformer.count", -1) do
      delete medium_voltage_transformer_url(@medium_voltage_transformer)
    end

    assert_redirected_to medium_voltage_transformers_url
  end
end
