class OrderLinesController < ApplicationController


  before_filter :authorize
  before_action :set_order_line, only: [:show, :edit, :update, :destroy, :shipment_graphs]

 
  # GET /order_lines
  # GET /order_lines.json


  def file_upload
   render partial: "shared/file_upload", locals: {target_path: import_file_order_lines_path}
  end

  def shipment_graphs
    @order_line = OrderLine.find(params[:id])
    @root_shipments = @order_line.immediate_shipment_lines
    @graphs = []
    @root_shipments.each do |shipment|
      graph = ShipmentGraph.new(shipment)
      @graphs << graph
    end
    respond_to do |format|
      format.js
    end
  end

  def import_file
    order_line_file = params[:file]
    copy_order_line_file(order_line_file)    
    OrderLine.import(Rails.root.join('public','order_line_uploads').to_s + "/"+order_line_file.original_filename)
    redirect_to order_lines_url 
  end

  def index
    @user = User.find(session[:user_id])
    @user_org = @user.organization
    @products = @user_org.products
    @locations = @user_org.locations
    @all_order_lines = @user_org.order_lines
    @organizations = Organization.all
    @product_categories = @user_org.product_categories
    search_hash = search_params
    if search_hash
      @order_lines = @all_order_lines.where(search_hash).order(:order_line_number)
      unless @order_lines.empty?
        @order_line = @order_lines.first 
        @root_shipments = @order_line.immediate_shipment_lines
        @graphs = []
        @root_shipments.each do |shipment|
          graph = ShipmentGraph.new(shipment)
          @graphs << graph
        end
      end
    end
  end

  # GET /order_lines/1
  # GET /order_lines/1.json
  def show
    respond_to do |format|
      format.html
      format.json {render json: @order_line, methods: [:product_name]}
    end
  end

  # GET /order_lines/new
  def new
    @order_line = OrderLine.new
    @user = User.find(session[:user_id])
    @user_org = @user.organization
    @products = @user_org.products
    @locations = @user_org.locations
    @organizations = Organization.all
  end

  # GET /order_lines/1/edit
  def edit
    @user = User.find(session[:user_id])
    @user_org = @user.organization
    @products = @user_org.products
    @locations = @user_org.locations
    @organizations = Organization.all
  end

  # POST /order_lines
  # POST /order_lines.json
  def create
    @order_line = OrderLine.new(order_line_params)

    respond_to do |format|
      if @order_line.save 
        format.html { redirect_to @order_line, notice: 'Order line was successfully created.' }
        format.json { render :show, status: :created, location: @order_line }
      else
        format.html do
          @user = User.find(session[:user_id])
          @user_org = @user.organization
          @products = @user_org.products
          @locations = @user_org.locations
          @organizations = Organization.all
          render :new 
        end
        format.json { render json: @order_line.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /order_lines/1
  # PATCH/PUT /order_lines/1.json
  def update
    respond_to do |format|
      if @order_line.update(order_line_params)
        format.html { redirect_to @order_line, notice: 'Order line was successfully updated.' }
        format.json { render :show, status: :ok, location: @order_line }
      else
        format.html do
          @user = User.find(session[:user_id])
          @user_org = @user.organization
          @products = @user_org.products
          @locations = @user_org.locations
          @organizations = Organization.all
          render :edit 
        end
        format.json { render json: @order_line.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /order_lines/1
  # DELETE /order_lines/1.json
  def destroy
    @order_line.destroy
    respond_to do |format|
      format.html { redirect_to order_lines_url, notice: 'Order line was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order_line
      @order_line = OrderLine.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_line_params
      params.require(:order_line).permit(:status, :order_type, :is_active, :product_name, :order_line_number, :quantity, :eta, :etd, :origin_location_id, :destination_location_id, :supplier_organization_id, :customer_organization_id, :product_category_name, :product_category_id, :origin_location_group_id, :origin_location_group_name, :destination_location_group_id, :destination_location_group_name)
    end

    def search_params
      user_params = nil
      if params[:order_line]
        logger.debug "params submitted"
        user_params = order_line_params.delete_if {|k,v| v.blank?}
        if user_params.key?("product_name")
          user_params["product_id"] =  Product.where(name: user_params["product_name"]).first.try(:id)
        elsif user_params.key?("product_category_id")
          user_params["product_id"] =  Product.where(product_category_id: user_params["product_category_id"]).try(:ids)
        elsif user_params.key?("product_category_name")
          user_params["product_id"] = ProductCategory.where(name: user_params["product_category_name"]).first.try(:products).try(:ids)
        end
        if user_params.key?("origin_location_group_id")
          user_params["origin_location_id"] = Location.where(location_group_id: user_params["origin_location_group_id"]).try(:ids)
        elsif user_params.key?("origin_location_group_name")
          user_params["origin_location_id"] = LocationGroup.where(name: user_params["origin_location_group_name"]).first.try(:locations).try(:ids)
        end
        if user_params.key?("destination_location_group_id")
          user_params["destination_location_id"] = Location.where(location_group_id: user_params["destination_location_group_id"]).try(:ids)
        elsif user_params.key?("destination_location_group_name")
          user_params["destination_location_id"] = LocationGroup.where(name: user_params["destination_location_group_name"]).first.try(:locations).try(:ids)
        end
        user_params.each {|k,v| (k.include?("_name") or k.include?("_group_id") or k.include?("_category_id")) ? user_params.delete(k) : nil }    
      end
      logger.debug user_params.to_s
      return user_params
    end

    def copy_order_line_file(order_line_file)
      File.open(Rails.root.join('public','order_line_uploads',order_line_file.original_filename),"wb") do |file|
        file.write(order_line_file.read)
      end
    end

end
