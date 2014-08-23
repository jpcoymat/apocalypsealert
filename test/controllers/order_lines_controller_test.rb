require 'test_helper'

class OrderLinesControllerTest < ActionController::TestCase
  setup do
    @order_line = order_lines(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:order_lines)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create order_line" do
    assert_difference('OrderLine.count') do
      post :create, order_line: { destination_location_id: @order_line.destination_location_id, eta: @order_line.eta, etd: @order_line.etd, order_line_number: @order_line.order_line_number, origin_location_id: @order_line.origin_location_id, quantity: @order_line.quantity }
    end

    assert_redirected_to order_line_path(assigns(:order_line))
  end

  test "should show order_line" do
    get :show, id: @order_line
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @order_line
    assert_response :success
  end

  test "should update order_line" do
    patch :update, id: @order_line, order_line: { destination_location_id: @order_line.destination_location_id, eta: @order_line.eta, etd: @order_line.etd, order_line_number: @order_line.order_line_number, origin_location_id: @order_line.origin_location_id, quantity: @order_line.quantity }
    assert_redirected_to order_line_path(assigns(:order_line))
  end

  test "should destroy order_line" do
    assert_difference('OrderLine.count', -1) do
      delete :destroy, id: @order_line
    end

    assert_redirected_to order_lines_path
  end
end