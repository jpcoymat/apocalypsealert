class AggregationsController < ApplicationController

  before_filter :authorize
  before_action :set_master_data, :set_global_filter

  def global
  end

  def source
    @source_filter = Filter.new("source")
    @suppliers = FilterElement.new("suppliers")
    @source_filter.filter_elements = [@suppliers]
    
  end

  def move
    @move_filter = Filter.new("move")
    @modes = FilterElement.new("mode")
    @carriers = FilterElement.new("carriers")
    @forwarders = FilterElement.new("forwarders")
    @move_filter.filter_elements = [@modes, @carriers, @forwarders]
  end
  
  protected
  
    def set_master_data
      @user_org = User.find(session[:user_id]).organization
      @locations = @user_org.exception_locations
      @product_categories = @user_org.product_categories
      @location_groups  = @user_org.location_groups 
      @other_orgs = Organization.where("id != ?", @user_org.id)
    end
    
    def set_global_filter
      @global_filter = Filter.new("global")
      @products = FilterElement.new("products")
      @product_categories = FilterElement.new("product_categories")
      @origin_locations = FilterElement.new("origin_locations")
      @origin_location_groups = FilterElement.new("origin_location_groups")
      @destination_locations = FilterElement.new("destination_locations")
      @destination_location_groups = FilterElement.new("destination_location_groups")
      @global_filter.filter_elements = [@products, @product_categories, @origin_locations, @origin_location_groups, @destination_locations, @destination_location_groups]
    end

  
end
