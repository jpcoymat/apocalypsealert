require 'test_helper'

class AggregationsControllerTest < ActionController::TestCase
  test "should get global" do
    get :global
    assert_response :success
  end

  test "should get source" do
    get :source
    assert_response :success
  end

  test "should get move" do
    get :move
    assert_response :success
  end

end
