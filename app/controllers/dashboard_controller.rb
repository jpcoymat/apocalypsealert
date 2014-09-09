class DashboardController < ApplicationController

  before_filter :authorize


  def index
    @user_org = User.find(session[:user_id]).organization
    @locations = @user_org.locations
    if categories_parameter[:product_id]
      @product = Product.find(categories_parameter[:product_id]).first
    elsif categories_parameter[:product_code]
      @product = Product.where(code: categories_parameter[:product_code]).first      
    else
      @product = Product.first
    end 

  end

  private

    def map_parameters
      params.require(:map_params).permit(:product_id, :product_code, :locaction_id, :location_name)
    end

    def categories_parameter
      params.require(:category_params).permit(:product_id, :product_code, :location_id, :location_name)
    end

end
