require 'test_helper'

class MilestonesControllerTest < ActionController::TestCase
  setup do
    @milestone = milestones(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:milestones)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create milestone" do
    assert_difference('Milestone.count') do
      post :create, milestone: { associated_object_id: @milestone.associated_object_id, associated_object_type: @milestone.associated_object_type, city: @milestone.city, country: @milestone.country, create_organization_id: @milestone.create_organization_id, create_user_id: @milestone.create_user_id, customer_organization_id: @milestone.customer_organization_id, milestone_type: @milestone.milestone_type, quantity: @milestone.quantity, reason_code: @milestone.reason_code }
    end

    assert_redirected_to milestone_path(assigns(:milestone))
  end

  test "should show milestone" do
    get :show, id: @milestone
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @milestone
    assert_response :success
  end

  test "should update milestone" do
    patch :update, id: @milestone, milestone: { associated_object_id: @milestone.associated_object_id, associated_object_type: @milestone.associated_object_type, city: @milestone.city, country: @milestone.country, create_organization_id: @milestone.create_organization_id, create_user_id: @milestone.create_user_id, customer_organization_id: @milestone.customer_organization_id, milestone_type: @milestone.milestone_type, quantity: @milestone.quantity, reason_code: @milestone.reason_code }
    assert_redirected_to milestone_path(assigns(:milestone))
  end

  test "should destroy milestone" do
    assert_difference('Milestone.count', -1) do
      delete :destroy, id: @milestone
    end

    assert_redirected_to milestones_path
  end
end
