require 'test_helper'

class InventoryProjectionsControllerTest < ActionController::TestCase
  setup do
    @inventory_projection = inventory_projections(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:inventory_projections)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create inventory_projection" do
    assert_difference('InventoryProjection.count') do
      post :create, inventory_projection: { available_quantity: @inventory_projection.available_quantity, location_id: @inventory_projection.location_id, product_id: @inventory_projection.product_id, projected_for: @inventory_projection.projected_for }
    end

    assert_redirected_to inventory_projection_path(assigns(:inventory_projection))
  end

  test "should show inventory_projection" do
    get :show, id: @inventory_projection
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @inventory_projection
    assert_response :success
  end

  test "should update inventory_projection" do
    patch :update, id: @inventory_projection, inventory_projection: { available_quantity: @inventory_projection.available_quantity, location_id: @inventory_projection.location_id, product_id: @inventory_projection.product_id, projected_for: @inventory_projection.projected_for }
    assert_redirected_to inventory_projection_path(assigns(:inventory_projection))
  end

  test "should destroy inventory_projection" do
    assert_difference('InventoryProjection.count', -1) do
      delete :destroy, id: @inventory_projection
    end

    assert_redirected_to inventory_projections_path
  end
end
