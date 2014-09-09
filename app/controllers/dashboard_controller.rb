class DashboardController < ApplicationController

  before_filter :authorize


  def index
    @user_org = User.find(session[:user_id]).organization
    @locations = @user_org.locations
    if params[:map_params] 
      if categories_parameter[:product_id]
        @map_product = Product.find(categories_parameter[:product_id]).first
      elsif categories_parameter[:product_code]
        @map_product = Product.where(code: categories_parameter[:product_code]).first      
      else
        @map_product = Product.first
      end
      if categories_parameter[:location_id]
        @map_location = Location.find(categories_parameter[:location_id]).first
      elsif categories_parameter[:location_code]
        @map_location = Location.where(code: categories_parameter[:location_code]).first
      else
        @map_location = Product.first
      end
    else 
      @map_location = Product.first    
      @map_product = Product.first
    end
    if params[:categories_parameter]
      if categories_parameter[:location_id]  
        @category_location = Location.find(categories_parameter[:location_id])
      elsif categories_parameter[:location_code]
        @category_location = Location.where(code: categories_parameter[:location_code]).first
      else
        @category_location = Location.first
      end
      if categories_parameter[:product_id]
        @category_product = Product.find(categories_parameter[:product_id])
      elsif categories_parameter[:product_code]
        @category_product = Product.where(code: categories_parameter[:product_code]).first
      else
        @category_product = Product.first
      end
    else
      @category_product = Product.first
      @category_location = Location.first  
    end
    @source_exceptions = @category_location.inbound_order_line_exceptions(product_id: @category_product.id)
    @move_exceptions = @category_location.inbound_shipmment_line_exceptions(product_id: @category_product.id)
    @store_exceptions = @category_location.inventory_exceptions(product_id: @category_product.id)
    @deliver_exceptions = @category_location.outbound_shipment_line_exceptions(product_id: @category_product.id)
  end

  private

    def map_parameters
      params.require(:map_params).permit(:product_id, :product_code, :locaction_id, :location_code)
    end

    def categories_parameter
      params.require(:category_params).permit(:product_id, :product_code, :location_id, :location_code)
    end

end
