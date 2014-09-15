class SummaryViewsController < ApplicationController

  before_filter :authorize

  def index
    @location = Location.where(name: params[:summary_parameters][:location_name]).first    
    @exceptions = []
    case params[:summary_parameters][:exception_category]
      when "Source"
         @exceptions = @location.inbound_order_line_exceptions
      when "Move"
         @exceptions = @location.inbound_shipment_line_exceptions 
      when "Store"
         @exceptions = @location.inventory_exceptions
      when "Deliver"  
         @exceptions = @location.outbound_order_line_exceptions
    end
    quantity_exception_count = 0
    date_exception_count = 0
    @exceptions.each {|excptn| excptn.exception_type == 'Quantity' ? quantity_exception_count += 1 : date_exception_count += 1}
    @pie_chart_data = {quantity_exceptions: quantity_exception_count, date_exceptions: date_exception_count}
  end

  def location_exceptions
    @location = Location.where(code: params[:location_details][:location_code]).first
    
  end


  protected
   
    def summary_params
      params.require(:summary_parameters).permit(:location_name, :product_code, :product_name, :exception_category)
    end
   
    def location_details_parameters
      params.require(:location_details).permit(:location_code)
    end


end
