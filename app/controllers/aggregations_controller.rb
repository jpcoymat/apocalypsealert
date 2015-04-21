class AggregationsController < ApplicationController

  before_filter :authorize
  before_action :set_global_filter, only: [:global, :source, :move]
  before_action :populate_filter_parameters, only: [:global, :source, :move]

  def global
    logger.debug @filter_object.filter_elements.to_s
    @user_org = User.find(session[:user_id]).organization
    @target_url = aggregations_refresh_global_path
    @chart_div_id = "global_view"
    @default_group_by = "global"
    @order_line_data = OrderLine.select("sum(quantity) as quantity, sum(total_cost) as total_cost").where(customer_organization_id: @user_org.id)[0]
    @ship_line_data = ShipmentLine.select("sum(quantity) as quantity, sum(total_cost) as total_cost").where(customer_organization_id: @user_org.id)[0]
    @initial_data = {global: {
                      series: {
                        quantity: {
                          name: "Quantity", 
                          data: [@order_line_data.quantity.to_i, @ship_line_data.quantity.to_i ] 
                        },
                        cost: {
                          name: "Cost", 
                          data: [@order_line_data.total_cost.to_i , @ship_line_data.total_cost.to_i] 
                        }
                      },
                      chart_categories: ["Source","Move"] 
                    }}
                     
  end

  def refresh_global
    shipment_ids, order_ids = [], []
    order_attribute_results, shipment_attribute_results = {}, {}
    user_params = params
    user_params.delete("controller")
    user_params.delete("action")    
    unless user_params.empty?
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
    else
      user_org = User.find(session[:user_id]).organization
      order_ids = user_org.order_lines.ids
      shipment_ids = user_org.shipment_lines.ids
    end
    @order_line_data = OrderLine.select("sum(quantity) as quantity, sum(total_cost) as total_cost").where(id: order_ids)[0]
    @ship_line_data = ShipmentLine.select("sum(quantity) as quantity, sum(total_cost) as total_cost").where(id: shipment_ids)[0]
    @response = {global: {
                      series: {
                        quantity: {
                          name: "Quantity", 
                          data: [@order_line_data.quantity.to_i, @ship_line_data.quantity.to_i ] 
                        },
                        cost: {
                          name: "Cost", 
                          data: [@order_line_data.total_cost.to_i , @ship_line_data.total_cost.to_i] 
                        }
                      },
                      chart_categories: ["Source","Move"] 
                    }} 
    logger.debug @response.to_json
    respond_to do |format|
      format.json {render json: @response }
      format.html {render json: @response }
    end
  end


  def source
    @filter_object.filter_elements << FilterElement.new(element_name: "supplier_organization_id", multiselectable: true, enabled_for_quick_filter: true, typeahead_enabled: true, filter_options: @other_orgs)
    @target_url = aggregations_refresh_source_path
    @chart_div_id = "source_view"        
    source_chart_data
    
  end

  def refresh_source
    source_chart_data
    respond_to do |format|
      format.html {render json: @chart_data }
      format.json {render json: @chart_data }
    end
  end

  def move
    @filter_object.filter_elements << FilterElement.new(element_name: "mode", multiselectable: true, enabled_for_quick_filter: true, typeahead_enabled: true, filter_options: ShipmentLine.modes)
    @filter_object.filter_elements << FilterElement.new(element_name: "carrier_organization_id", multiselectable: true, enabled_for_quick_filter: true, typeahead_enabled: true, filter_options: @other_orgs)
    @filter_object.filter_elements << FilterElement.new(element_name: "forwarder_organization_id", multiselectable: true, enabled_for_quick_filter: true, typeahead_enabled: true,filter_options: @other_orgs)
  end


  def refresh_move
    
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
      @filter_object = Filter.new(filter_name: "global")
      @products_filter = FilterElement.new(element_name: "product_id", filter_options: @products, multiselectable: true, enabled_for_quick_filter: true)
      @product_categories_filter = FilterElement.new(element_name: "product_category_id", multiselectable: true, enabled_for_quick_filter: true, filter_options: @product_categories)
      @origin_locations_filter = FilterElement.new(element_name: "origin_location_id", multiselectable: true, enabled_for_quick_filter: true, filter_options: @locations)
      @origin_location_groups_filter = FilterElement.new(element_name: "origin_location_group_id", multiselectable: true, enabled_for_quick_filter: true, filter_options: @location_groups)
      @destination_locations_filter = FilterElement.new(element_name: "destination_location_id", multiselectable: true, enabled_for_quick_filter: true, filter_options: @locations)
      @destination_location_groups_filter = FilterElement.new(element_name: "destination_location_group_id", multiselectable: true, enabled_for_quick_filter: true, filter_options: @location_groups)
      @filter_object.filter_elements = [@products_filter, @product_categories_filter, @origin_locations_filter, @origin_location_groups_filter, @destination_locations_filter, @destination_location_groups_filter]
    end

    def object_filter(object_class)
      object_ids = []
      object_attribute_results = {}
      user_params = params
      user_params.delete("controller")
      user_params.delete("action")   
      unless user_params.empty? 
        user_params.each do |key,value|
          object_attribute_results[key] = []
          values = value.split(",").map { |s| s.to_i }
          for val in values
            at = AttributeTracker.new(object_class, key, val)
            object_attribute_results[key] += at.value 
          end
        end
        object_ids = object_attribute_results[object_attribute_results.first.first]
        object_attribute_results.each do |k,v|
          object_ids &= v unless k==object_attribute_results.first.first
        end
      else
        object_ids = eval("#{object_class}.records_for_organization(organization: User.find(session[:user_id]).organization)")
      end
      return object_ids
    end
    
    def populate_filter_parameters
      params.each do |k,v|
        array_index = @filter_object.filter_elements.find_index {|filter_elem| filter_elem.element_name == k}
        if array_index
          @filter_object.filter_elements[array_index].element_value = v
        end
      end
    end
    
    def move_chart_data
      @shipment_line_ids = object_filter("ShipmentLine")
      @shipment_lines = ShipmentLine.where(id: @shipment_line_ids)
    end
    
    def source_chart_data
      @product_categories = User.find(session[:user_id]).organization.product_categories
      @order_line_ids = object_filter("OrderLine")
      @order_lines = OrderLine.select("sum(quantity) as quantity, sum(total_cost) as total_cost").where(id: @order_line_ids)
      @initial_data = {}
      quantity_hash, cost_hash = {}, {}
      OrderLine.statuses.each do |k,v|
        status_quantity_hash = {name: k.titleize, status_value: v} 
        status_cost_hash = {name: k.titleize, status_value: v} 
        status_quantity_data, status_cost_data = [], []
        @product_categories.each do |pc|
          order_line_data = @order_lines.where(product_id: pc.products, status: v)[0]
          status_quantity_data <<  order_line_data.quantity.to_i
          status_cost_data << order_line_data.quantity.to_i
        end
        status_quantity_hash[:data], status_cost_hash[:data] = status_quantity_data, status_cost_data        
      end
      logger.debug @initial_data
      @initial_data 
    end
  
end
