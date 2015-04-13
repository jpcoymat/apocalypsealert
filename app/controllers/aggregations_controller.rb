class AggregationsController < ApplicationController

  before_filter :authorize
  before_action :set_global_filter

  def global
    @filter_partial = "global_filter"
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
      @user = User.find(session[:user_id])
      @user_org = @user.organization
      @products = @user_org.products
      @locations = @user_org.locations
      @product_categories = @user_org.product_categories
      @location_groups  = @user_org.location_groups 
      @other_orgs = Organization.where("id != ?", @user_org.id)
    end
    
    def set_global_filter
      set_master_data
      @global_filter = Filter.new(filter_name: "global")
      @products_filter = FilterElement.new(element_name: "products", filter_options: @products, multiselectable: true)
      @product_categories_filter = FilterElement.new(element_name: "product_categories", multiselectable: true, filter_options: @product_categories)
      @origin_locations_filter = FilterElement.new(element_name: "origin_locations", multiselectable: true, filter_options: @locations)
      @origin_location_groups_filter = FilterElement.new(element_name: "origin_location_groups", multiselectable: true, filter_options: @location_groups)
      @destination_locations_filter = FilterElement.new(element_name: "destination_locations", multiselectable: true, filter_options: @locations)
      @destination_location_groups_filter = FilterElement.new(element_name: "destination_location_groups", multiselectable: true, filter_options: @location_groups)
      @global_filter.filter_elements = [@products_filter, @product_categories_filter, @origin_locations_filter, @origin_location_groups_filter, @destination_locations_filter, @destination_location_groups_filter]
    end

  
end
