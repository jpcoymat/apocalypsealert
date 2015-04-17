require 'test_helper'

class BuyerGroupsControllerTest < ActionController::TestCase
  setup do
    @buyer_group = buyer_groups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:buyer_groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create buyer_group" do
    assert_difference('BuyerGroup.count') do
      post :create, buyer_group: { description: @buyer_group.description, name: @buyer_group.name, organization_id: @buyer_group.organization_id }
    end

    assert_redirected_to buyer_group_path(assigns(:buyer_group))
  end

  test "should show buyer_group" do
    get :show, id: @buyer_group
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @buyer_group
    assert_response :success
  end

  test "should update buyer_group" do
    patch :update, id: @buyer_group, buyer_group: { description: @buyer_group.description, name: @buyer_group.name, organization_id: @buyer_group.organization_id }
    assert_redirected_to buyer_group_path(assigns(:buyer_group))
  end

  test "should destroy buyer_group" do
    assert_difference('BuyerGroup.count', -1) do
      delete :destroy, id: @buyer_group
    end

    assert_redirected_to buyer_groups_path
  end
end
