class SummaryViewsController < ApplicationController

  before_filter :authorize

  def index
    @location = Location.where(name: params[:summary_parameters][:location_name]).first    
  end

  protected
   
    def summary_params
      params.require(:summary_parameters).permit(:location_name, :product_code, :product_name)
    end

end
