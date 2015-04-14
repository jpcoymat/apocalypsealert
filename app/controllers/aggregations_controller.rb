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
  
  def refresh_global
    shipment_ids, order_ids = [], []
    order_attribute_results, shipment_attribute_results = {}, {}
    user_params = params
    user_params.delete("controller")
    user_params.delete("action")    
    user_params.each do |key,value|
      order_attribute_results[key], shipment_attribute_results[key] = [],[] 
      values = value.split(",").map { |s| s.to_i }
      for val in values
        oat = AttributeTracker.new("OrderLine", key, val)
        order_attribute_results[key] += oat.value
        sat = AttributeTracker.new("ShipmentLine", key, val)
        shipment_attribute_results[key] += sat.value 
      end
    end
    order_ids = order_attribute_results[order_attribute_results.first.first]
    order_attribute_results.each do |k,v|
      order_ids &= v unless k==order_attribute_results.first.first
    end
    shipment_ids = shipment_attribute_results[shipment_attribute_results.first.first]
    shipment_attribute_results.each do |k,v|
      shipment_ids &= v unless k==shipment_attribute_results.first.first
    end
    @response = [{name: "Quantity", data: [OrderLine.where(id: order_ids).sum(:quantity), 
                                          ShipmentLine.where(id: shipment_ids).sum(:quantity) ] } ]
    respond_to do |format|
      format.json {render json: @response }
      format.html {render json: @response }
    end
  end
     
  def source
    shipment_ids = []
    shipment_attribute_results = {}
    user_params = params
    user_params.delete("controller")
    user_params.delete("action")    
    user_params.each do |key,value|
      shipment_attribute_results[key] = []
      values = value.split(",").map { |s| s.to_i }
      for val in values
        sat = AttributeTracker.new("ShipmentLine", key, val)
        shipment_attribute_results[key] += sat.value 
      end
    end
    shipment_ids = shipment_attribute_results[shipment_attribute_results.first.first]
    shipment_attribute_results.each do |k,v|
      shipment_ids &= v unless k==shipment_attribute_results.first.first
    end
    
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
      @products_filter = FilterElement.new(element_name: "product_id", filter_options: @products, multiselectable: true, enabled_for_quick_filter: true)
      @product_categories_filter = FilterElement.new(element_name: "product_category_id", multiselectable: true, enabled_for_quick_filter: true, filter_options: @product_categories)
      @origin_locations_filter = FilterElement.new(element_name: "origin_location_id", multiselectable: true, enabled_for_quick_filter: true, filter_options: @locations)
      @origin_location_groups_filter = FilterElement.new(element_name: "origin_location_group_id", multiselectable: true, enabled_for_quick_filter: true, filter_options: @location_groups)
      @destination_locations_filter = FilterElement.new(element_name: "destination_location_id", multiselectable: true, enabled_for_quick_filter: true, filter_options: @locations)
      @destination_location_groups_filter = FilterElement.new(element_name: "destination_location_group_id", multiselectable: true, enabled_for_quick_filter: true, filter_options: @location_groups)
      @global_filter.filter_elements = [@products_filter, @product_categories_filter, @origin_locations_filter, @origin_location_groups_filter, @destination_locations_filter, @destination_location_groups_filter]
    end

  
end
