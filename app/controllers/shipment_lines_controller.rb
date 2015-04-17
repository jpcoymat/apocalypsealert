class ShipmentLinesController < ApplicationController

  before_filter :authorize
  before_action :set_shipment_line, only: [:show, :edit, :update, :destroy]

  def lookup
    @user = User.find(session[:user_id])
    @user_org = @user.organization
    @organizations = Organization.all
    @products = @user_org.products
    @locations = @user_org.locations
    @order_lines = @user_org.order_lines
    @all_shipment_lines = @user_org.shipment_lines
    if request.post?
      @shipment_lines = @all_shipment_lines.where(search_params).order(:shipment_line_number)
      @order_line = order_param
      if @order_line
        @shipment_lines = @shipment_lines.where("id in (select shipment_line_id from order_itineraries where order_line_id = #{@order_line.id})")
      end
      @shipment_lines
    end
  end

  def order_line_shipment_graphs
    @order_line = order_param
    @root_shipments = @order_line.immediate_shipment_lines
    @graphs = []
    @root_shipments.each do |shipment| 
      graph = ShipmentGraph.new(shipment)
      @graphs << graph
    end
  end

  # GET /shipment_lines
  # GET /shipment_lines.json
  def index
    @shipment_lines = ShipmentLine.all
  end

  # GET /shipment_lines/1
  # GET /shipment_lines/1.json
  def show
  end

  # GET /shipment_lines/new
  def new
    @user_org= User.find(session[:user_id]).organization
    @organizations = Organization.all
    @order_lines = @user_org.order_lines
    @shipment_line = ShipmentLine.new
    @products = @user_org.products
    @locations = @user_org.locations
  end

  # GET /shipment_lines/1/edit
  def edit
    @user_org= User.find(session[:user_id]).organization
    @organizations = Organization.all
    @order_lines = @user_org.order_lines
    @products = @user_org.products
    @locations = @user_org.locations
  end

  # POST /shipment_lines
  # POST /shipment_lines.json
  def create
    @shipment_line = ShipmentLine.new(shipment_line_params)
    respond_to do |format|
      if @shipment_line.save
        @order_line = order_param
        if @order_line
          @order_itinerary = OrderItinerary.new(shipment_line: @shipment_line, order_line: @order_line)
          @order_itinerary.set_leg_number
          @order_itinerary.save
          @order_itinerary.set_previous_order_itinerary
        end
        format.html { redirect_to lookup_shipment_lines_path, notice: 'Shipment line was successfully created.' }
        format.json { render :show, status: :created, location: @shipment_line }
      else
        format.html do
          @user_org= User.find(session[:user_id]).organization
          @organizations = Organization.all
          @order_lines = @user_org.order_lines
          @products = @user_org.products
          @locations = @user_org.locations
          render :new 
        end
        format.json { render json: @shipment_line.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shipment_lines/1
  # PATCH/PUT /shipment_lines/1.json
  def update
    respond_to do |format|
      if @shipment_line.update(shipment_line_params)
        format.html { redirect_to lookup_shipment_lines_path, notice: 'Shipment line was successfully updated.' }
        format.json { render :show, status: :ok, location: @shipment_line }
      else
        format.html do 
          @user_org= User.find(session[:user_id]).organization
          @organizations = Organization.all
          @order_lines = @user_org.order_lines
          @products = @user_org.products
          @locations = @user_org.locations
          render :edit  
        end
        format.json { render json: @shipment_line.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shipment_lines/1
  # DELETE /shipment_lines/1.json
  def destroy
    @shipment_line.destroy
    respond_to do |format|
      format.html { redirect_to shipment_lines_url, notice: 'Shipment line was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  def file_upload
    render partial: "shared/file_upload", locals: {target_path: import_file_shipment_lines_path}
  end

  def import_file
    shipment_line_file = params[:file]
    copy_shipment_line_file(shipment_line_file)
    ShipmentLine.import(Rails.root.join('public','shipment_line_uploads').to_s + "/" + shipment_line_file.original_filename)
    redirect_to lookup_shipment_lines_url
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shipment_line
      @shipment_line = ShipmentLine.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shipment_line_params
      params.require(:shipment_line).permit(:status, :shipment_type, :is_active, :mode, :shipment_line_number, :quantity, :eta, :etd, :origin_location_id, :destination_location_id, :product_id, :product_name, :customer_organization_id, :forwarder_organization_id, :carrier_organization_id, :total_cost, :total_weight, :total_volume)
    end

    def order_param
      ol = nil
      unless params[:shipment_line][:order_line_number].nil? or params[:shipment_line][:order_line_number].blank?
        ol = OrderLine.where(order_line_number: params[:shipment_line][:order_line_number]).first
      end
      ol
    end

    def search_params
      search_params = shipment_line_params.delete_if {|k,v| v.blank?}
      if search_params.key?("product_name")
        search_params["product_id"] =  Product.where(name: search_params["product_name"]).first.try(:id)
        search_params.delete("product_name")
      end
      search_params
    end

    def copy_shipment_line_file(shipment_line_file)
      File.open(Rails.root.join('public','shipment_line_uploads',shipment_line_file.original_filename),"wb") do |file|
        file.write(shipment_line_file.read)
      end
    end



end
