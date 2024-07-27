require "test_helper"

class UserSettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get user_settings_edit_url
    assert_response :success
  end

  test "should get update" do
    get user_settings_update_url
    assert_response :success
  end
end
