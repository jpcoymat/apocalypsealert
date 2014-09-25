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

  


  protected
   
    def summary_params
      params.require(:summary_parameters).permit(:location_name, :product_code, :product_name, :exception_category)
    end
   
    def location_details_parameters
      params.require(:location_details).permit(:location_code)
    end


end
