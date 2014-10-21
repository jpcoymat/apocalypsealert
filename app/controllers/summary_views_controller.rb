class SummaryViewsController < ApplicationController

  before_filter :authorize

  def location_exceptions
    @location = Location.where(code: params[:location_details][:location_code]).first
    @product_categories = User.find(session[:user_id]).organization.product_categories
  end

  def loc_group_prod_cat
    @location_group = LocationGroup.find(params[:location_group_id])
    @product_category = ProductCategory.find(params[:product_category_id])
  end


  def location_group_view
    @location_group = LocationGroup.where(name: params[:location_group_summary][:location_group_name]).first
    @locations = @location_group.locations
    @product_categories = @location_group.organization.product_categories
    @exception_category = params[:location_group_summary][:exception_category]
    @method_to_execute = ""
    case @exception_category
      when "Source"
        @method_to_execute = "source_exception_quantity"
      when "Make"
        @method_to_execute = "make_exception_quantity"
      when "Move"
        @method_to_execute = "move_exception_quantity"
      when "Store"
        @method_to_execute = "store_exception_quantity"
      when "Deliver"
        @method_to_execute = "deliver_exception_quantity"
      when "All"
        @method_to_execute = "all_exception_quantity"
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def product_category_view
    @product_category = ProductCategory.where(name: params[:product_category_summary][:product_category_name]).first
    @location_groups = @product_category.organization.location_groups
    @products = @product_category.products
    @exception_category = params[:product_category_summary][:exception_category]
    @method_to_execute = ""
    case @exception_category
      when "Source" 
        @method_to_execute = "source_exception_quantity"
      when "Make"
        @method_to_execute = "make_exception_quantity"
      when "Move"
        @method_to_execute = "move_exception_quantity"
      when "Store"
        @method_to_execute = "store_exception_quantity"
      when "Deliver"
        @method_to_execute = "deliver_exception_quantity"
      when "All"
        @method_to_execute = "all_exception_quantity"
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def category_breakdown
    @user_org = User.find(session[:user_id]).organization
    @location_groups = @user_org.location_groups
    @product_categories = @user_org.product_categories
    @scv_category = params[:scv_category]
    if params[:org_location_groups]
      @location_groups = @location_groups.where("id in (#{params[:org_location_groups]})")
    end
    if params[:org_product_categories] 
      @product_categories = @product_categories.where("id in (#{params[:org_product_categories]})")
    end
    @exception_method, @summary_method = "", ""
    case @scv_category
      when "Source"
        @exception_method = "source_exception_quantity"
        @summary_method = "inbound_order_line_quantity"
      when "Make"
        @exception_method = "make_exception_quantity"
        @summary_method = "work_order_quantity"
      when "Move"
        @exception_method = "move_exception_quantity"
        @summary_method = "inbound_shipment_line_quantity"
      when "Store"
        @exception_method = "store_exception_quantity"
        @summary_method = "inventory_projection_quantity"
      when "Deliver"
        @exception_method = "deliver_exception_quantity"
        @summary_method = "outbound_order_line_quantity"
    end
  end  


  protected
   
    def summary_params
      params.require(:summary_parameters).permit(:location_name, :product_code, :product_name, :exception_category)
    end
   
    def location_details_parameters
      params.require(:location_details).permit(:location_code)
    end


end
