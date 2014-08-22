require 'test_helper'

class ScvExceptionsControllerTest < ActionController::TestCase
  setup do
    @scv_exception = scv_exceptions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:scv_exceptions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create scv_exception" do
    assert_difference('ScvException.count') do
      post :create, scv_exception: { priority: @scv_exception.priority, status: @scv_exception.status, type: @scv_exception.type }
    end

    assert_redirected_to scv_exception_path(assigns(:scv_exception))
  end

  test "should show scv_exception" do
    get :show, id: @scv_exception
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @scv_exception
    assert_response :success
  end

  test "should update scv_exception" do
    patch :update, id: @scv_exception, scv_exception: { priority: @scv_exception.priority, status: @scv_exception.status, type: @scv_exception.type }
    assert_redirected_to scv_exception_path(assigns(:scv_exception))
  end

  test "should destroy scv_exception" do
    assert_difference('ScvException.count', -1) do
      delete :destroy, id: @scv_exception
    end

    assert_redirected_to scv_exceptions_path
  end
end
