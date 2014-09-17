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


  protected
   
    def summary_params
      params.require(:summary_parameters).permit(:location_name, :product_code, :product_name, :exception_category)
    end
   
    def location_details_parameters
      params.require(:location_details).permit(:location_code)
    end


end
