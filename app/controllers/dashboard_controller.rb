class DashboardController < ApplicationController

  before_filter :authorize


  def index
    @user_org = User.find(session[:user_id]).organization
    @locations = @user_org.locations
    @products = @user_org.products
    @map_product = Product.first
    @category_product = Product.first
    @category_location = Location.first  
    @source_exceptions = @category_location.inbound_order_line_exceptions(product_id: @category_product.id)
    @move_exceptions = @category_location.inbound_shipment_line_exceptions(product_id: @category_product.id)
    @store_exceptions = @category_location.inventory_exceptions(product_id: @category_product.id)
    @deliver_exceptions = @category_location.outbound_order_line_exceptions(product_id: @category_product.id)
  end

  def reset_map
    @user_org = User.find(session[:user_id]).organization
    @locations = @user_org.locations
    @products = @user_org.products
    @map_product = Product.where(name: params[:map_parameters][:product_name]).first
    @category_product = Product.first
    @category_location = Location.first
    @source_exceptions = @category_location.inbound_order_line_exceptions(product_id: @category_product.id)
    @move_exceptions = @category_location.inbound_shipment_line_exceptions(product_id: @category_product.id)
    @store_exceptions = @category_location.inventory_exceptions(product_id: @category_product.id)
    @deliver_exceptions = @category_location.outbound_order_line_exceptions(product_id: @category_product.id)
    render action: 'index'
  end

  def reset_category_exceptions
    @user_org = User.find(session[:user_id]).organization
    @locations = @user_org.locations
    @products = @user_org.products
    @map_product = Product.first
    @category_product = Product.where(name: params[:category_parameters][:product_name]).first
    @category_location = Location.find(params[:category_parameters][:location_id])
    @source_exceptions = @category_location.inbound_order_line_exceptions(product_id: @category_product.id)
    @move_exceptions = @category_location.inbound_shipment_line_exceptions(product_id: @category_product.id)
    @store_exceptions = @category_location.inventory_exceptions(product_id: @category_product.id)
    @deliver_exceptions = @category_location.outbound_order_line_exceptions(product_id: @category_product.id)
    render action: 'index'
  end

  private

    def map_params
      params.require(:map_parameters).permit(:product_id, :product_code, :locaction_id, :location_code)
    end

    def categories_params
      params.require(:category_parameters).permit(:product_id, :product_code, :location_id, :location_code, :product_name)
    end

end
