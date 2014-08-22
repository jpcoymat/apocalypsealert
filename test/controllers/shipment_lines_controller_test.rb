require 'test_helper'

class ShipmentLinesControllerTest < ActionController::TestCase
  setup do
    @shipment_line = shipment_lines(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:shipment_lines)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create shipment_line" do
    assert_difference('ShipmentLine.count') do
      post :create, shipment_line: { destination_location_id: @shipment_line.destination_location_id, eta: @shipment_line.eta, etd: @shipment_line.etd, order_line_id: @shipment_line.order_line_id, origin_location_id: @shipment_line.origin_location_id, quantity: @shipment_line.quantity, shipment_line_number: @shipment_line.shipment_line_number }
    end

    assert_redirected_to shipment_line_path(assigns(:shipment_line))
  end

  test "should show shipment_line" do
    get :show, id: @shipment_line
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @shipment_line
    assert_response :success
  end

  test "should update shipment_line" do
    patch :update, id: @shipment_line, shipment_line: { destination_location_id: @shipment_line.destination_location_id, eta: @shipment_line.eta, etd: @shipment_line.etd, order_line_id: @shipment_line.order_line_id, origin_location_id: @shipment_line.origin_location_id, quantity: @shipment_line.quantity, shipment_line_number: @shipment_line.shipment_line_number }
    assert_redirected_to shipment_line_path(assigns(:shipment_line))
  end

  test "should destroy shipment_line" do
    assert_difference('ShipmentLine.count', -1) do
      delete :destroy, id: @shipment_line
    end

    assert_redirected_to shipment_lines_path
  end
end
