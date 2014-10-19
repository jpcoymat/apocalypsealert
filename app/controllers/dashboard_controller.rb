class DashboardController < ApplicationController

  before_filter :authorize


  def index
    @user_org = User.find(session[:user_id]).organization
    @locations = @user_org.exception_locations
    @product_categories = @user_org.product_categories
    @location_groups  = @user_org.location_groups
    @prod_cat_log_grp_method = "all_exception_quantity"
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

  def redraw_prod_cat_log_grp_matrix
    @user_org = User.find(session[:user_id]).organization
    @product_categories = @user_org.product_categories
    @location_groups  = @user_org.location_groups
    @prod_cat_log_grp_method = params[:method_name] + "_exception_quantity"
    respond_to do |format|
      format.js
    end
  end

  def recalculate_product_category_exceptions
    @user_org = User.find(session[:user_id]).organization
    @product_categories = @user_org.product_categories
    location_groups = params[:location_groups]
    @response = []
    @product_categories.each do |pc|
      @response << {name: pc.name, data: [pc.source_exception_quantity(destination_location_groups: location_groups).to_i, 
					pc.make_exception_quantity(location_groups: location_groups).to_i, 
					pc.move_exception_quantity(destination_location_groups: location_groups).to_i,
                                        pc.store_exception_quantity(location_groups: location_groups).to_i, 
					pc.deliver_exception_quantity(origin_location_groups: location_groups).to_i]}
    end  
    respond_to do |format|
      format.json {render json: @response}
      format.html {render json: @response} 
    end  
  end

  def recalculate_location_group_exceptions
    @user_org = User.find(session[:user_id]).organization
    @location_groups = @user_org.location_groups
    product_categories = params[:product_categories]
    @response = []
    @location_groups.each do |lg|
      @response << {name: lg.name, data: [lg.source_exception_quantity(product_categories: product_categories).to_i,
					  lg.make_exception_quantity(product_categories: product_categories).to_i,
                                          lg.move_exception_quantity(product_categories: product_categories).to_i,
                                          lg.store_exception_quantity(product_categories: product_categories).to_i,
                                          lg.deliver_exception_quantity(product_categories: product_categories).to_i]}
    end
    respond_to do |format|
      format.json {render json: @response}
      format.html {render json: @response}
    end
  end

  def recalculate_org_exceptions
    @user_org = User.find(session[:user_id]).organization
    loc_groups = params[:org_location_groups]
    prod_cats = params[:org_product_categories]
    search_params = {}
    search_params[:product_categories] = prod_cats unless (prod_cats.nil? or prod_cats.blank?)
    unless (loc_groups.nil? or loc_groups.blank?)
      search_params[:location_groups] = loc_groups
      search_params[:destination_location_groups] = loc_groups
      search_params[:origin_location_groups] = loc_groups
    end
    @response = [{name: "Exception Quantity",
                  data: [@user_org.source_exception_quantity(search_params),
                         @user_org.make_exception_quantity(search_params),
                         @user_org.move_exception_quantity(search_params),
                         @user_org.store_exception_quantity(search_params),
                         @user_org.deliver_exception_quantity(search_params) 
                        ]
                 },
                 {name: "On Schedule Quantity",
                  data:[ @user_org.inbound_order_quantity(search_params) - @user_org.source_exception_quantity(search_params),   
                         @user_org.work_order_quantity(search_params) - @user_org.source_exception_quantity(search_params) ,
                         @user_org.inbound_shipment_quantity(search_params) - @user_org.move_exception_quantity(search_params),
                         @user_org.inventory_projection_quantity(search_params) - @user_org.store_exception_quantity(search_params),
                         @user_org.outbound_order_quantity(search_params) - @user_org.deliver_exception_quantity(search_params)
                       ]
                 }]
    respond_to do |format|
      format.json {render json: @response}
      format.html {render json: @response}
    end 
  end

  private

    def map_params
      params.require(:map_parameters).permit(:product_id, :product_code, :locaction_id, :location_code)
    end

    def categories_params
      params.require(:category_parameters).permit(:product_id, :product_code, :location_id, :location_code, :product_name)
    end

   

end
