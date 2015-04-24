class AggregationsController < ApplicationController

  before_filter :authorize
  before_action :set_global_filter, only: [:global, :source, :move]
  before_action :populate_filter_parameters, only: [:global, :source, :move]
  before_action :set_saved_search_criterium, only: [:global, :source, :move]

  def global
    @user_org = User.find(session[:user_id]).organization
    @target_url = aggregations_refresh_global_path
    @chart_div_id = "global_view"
    @default_group_by = "global"
    @default_series = "global"
    order_ids = object_filter("OrderLine")
    shipment_ids = object_filter("ShipmentLine")
    @order_line_data = OrderLine.select("sum(quantity) as quantity, sum(total_cost) as total_cost").where(id: order_ids)[0]
    @ship_line_data = ShipmentLine.select("sum(quantity) as quantity, sum(total_cost) as total_cost").where(id: shipment_ids)[0]
    @initial_data = {global: {
                      series: {
                        global: {
                          name: "Global", 
                          data: {quantity: [@order_line_data.quantity.to_i, @ship_line_data.quantity.to_i ],
                                cost: [@order_line_data.total_cost.to_i , @ship_line_data.total_cost.to_i]}
                        }
                      },
                      chart_categories: ["Source","Move"] 
                    }}
                     
  end

  def refresh_global
    shipment_ids, order_ids = [], []
    order_attribute_results, shipment_attribute_results = {}, {}
    order_ids = object_filter("OrderLine", params)   
    shipment_ids = object_filter("ShipmentLine", params)
    @order_line_data = OrderLine.select("sum(quantity) as quantity, sum(total_cost) as total_cost").where(id: order_ids)[0]
    @ship_line_data = ShipmentLine.select("sum(quantity) as quantity, sum(total_cost) as total_cost").where(id: shipment_ids)[0]
    @response = {global: {
                      series: {
                        global: {
                          name: "Global", 
                          data: {quantity: [@order_line_data.quantity.to_i, @ship_line_data.quantity.to_i ],
                                cost: [@order_line_data.total_cost.to_i , @ship_line_data.total_cost.to_i]}
                        }
                      },
                      chart_categories: ["Source","Move"] 
                    }}
    respond_to do |format|
      format.json {render json: @response }
      format.html {render json: @response }
    end
  end


  def source
    @filter_object.filter_elements << FilterElement.new(element_name: "supplier_organization_id", multiselectable: true, enabled_for_quick_filter: true, typeahead_enabled: true, filter_options: @other_orgs)
    @target_url = aggregations_refresh_source_path
    @default_group_by = "product_categories"
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
      @page = page_requested
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

    def object_filter(object_class, search_params = params)
      object_ids = []
      object_attribute_results = {}
      user_params = search_params
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
      @initial_data = {product_categories: {
                        series: {},
                        chart_categories: @product_categories.pluck(:name)
                      },
                      origin_location_groups:{
                        series: {},
                        chart_categories: @location_groups.pluck(:name)
                      },
                      destination_location_groups: {
                        series: {},
                        chart_categories: @location_groups.pluck(:name)
                      }
      }
      OrderLine.statuses.each do |status_string, status_value| 
        product_category_status_series = {name: status_string, data: {quantity: [], cost: []}}
        @product_categories.each do |pc|
          @order_lines = OrderLine.select("sum(quantity) as quantity, sum(total_cost) as total_cost").where(id: @order_line_ids, product: pc.products, status: status_value)
          product_category_status_series[:data][:quantity] << @order_lines[0].quantity.to_i
          product_category_status_series[:data][:cost] << @order_lines[0].total_cost.to_i
        end
        @initial_data[:product_categories][:series][status_string] = product_category_status_series
      end
      logger.debug @initial_data.to_json
      @initial_data 
    end
    
    def set_saved_search_criterium
      @default_saved_criterium = @user.saved_search_criterium || {}
      logger.debug @default_saved_criterium.to_s
      @saved_search_criteria = SavedSearchCriterium.where(organization_id: @user_org.id, page: page_requested)
      logger.debug page_requested
    end
    
    def page_requested
      page = request.fullpath[/[^?]+/]
      page = page[1 .. page.length-1]
      page = page.partition("/").last
      return page  
    end
  
end
