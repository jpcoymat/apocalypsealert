class SummaryViewsController < ApplicationController

  before_filter :authorize

  def index
    
  end

  protected
   
    def summary_params
      params.require(:summary_parameters).permit(:location_name, :product_code, :product_name)
    end

end
