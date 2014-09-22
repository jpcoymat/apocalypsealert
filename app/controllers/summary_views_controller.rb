class SummaryViewsController < ApplicationController

  before_filter :authorize

  def index
    @location = Location.where(name: params[:summary_parameters][:location_name]).first    
    @exceptions = []
  end

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
    @product_categories = User.find(session[:user_id]).organization.product_categories
    @exception_category = params[:location_group_summary][:exception_category]
  end

  def product_category_view
    @product_category = ProductCategory.where(name: params[:product_category_summary][:product_category_name]).first
    @location_groups = User.find(session[:user_id]).organization.location_groups
    @exception_category = params[:product_category_summary][:exception_category]
  end


  protected
   
    def summary_params
      params.require(:summary_parameters).permit(:location_name, :product_code, :product_name, :exception_category)
    end
   
    def location_details_parameters
      params.require(:location_details).permit(:location_code)
    end


end
