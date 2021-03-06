class InventoryProjectionsController < ApplicationController
  before_filter :authorize
  before_action :set_inventory_projection, only: [:show, :edit, :update, :destroy]

  def lookup
    @user_org = User.find(session[:user_id]).organization
    @locations = @user_org.locations
    @products = @user_org.products
    @product_categories = @user_org.product_categories
    if request.post?
      @user_params = search_params(inventory_projection_search_params)
      @inventory_positions = InventoryProjection.inventory_positions(@user_params)
      @series_data = []
      if @inventory_positions.count > 0
        @inventory_positions.each do |inv_pos|
           inventory_data = []
           dates = []
           series = {product: inv_pos.product, location: inv_pos.location}
           InventoryProjection.position_projections(inv_pos).each do |proj|
             dates << proj.projected_for
             inventory_data << proj.available_quantity.to_i
           end
           series[:begin_date] = dates.min
           series[:end_date] = dates.max
           series[:data] = inventory_data
           @series_data << series
        end
      end
    end
  end


  def file_upload
    render partial: "shared/file_upload", locals: {target_path: import_file_inventory_projections_path}
  end

  def import_file
    inventory_file = params[:file]
    copy_inventory_file(inventory_file)
    InventoryProjection.import(Rails.root.join('public','inventory_uploads').to_s + "/" + inventory_file.original_filename)
    notice = "File has been processed"
    redirect_to lookup_inventory_projections_path
  end

  # GET /inventory_projections
  # GET /inventory_projections.json
  def index
    @inventory_projections = InventoryProjection.all
  end

  # GET /inventory_projections/1
  # GET /inventory_projections/1.json
  def show
  end

  # GET /inventory_projections/new
  def new
    @inventory_projection = InventoryProjection.new
    @user_org = User.find(session[:user_id])
    @locations = @user_org.locations
    @products = @user_org.products
  end

  # GET /inventory_projections/1/edit
  def edit
    @user_org = User.find(session[:user_id]).organization
    @user_org = User.find(session[:user_id])
    @locations = @user_org.locations
    @products = @user_org.products
  end

  # POST /inventory_projections
  # POST /inventory_projections.json
  def create
    @inventory_projection = InventoryProjection.new(inventory_projection_params)

    respond_to do |format|
      if @inventory_projection.save
        format.html { redirect_to @inventory_projection, notice: 'Inventory projection was successfully created.' }
        format.json { render :show, status: :created, location: @inventory_projection }
      else
        format.html do
          @user_org = User.find(session[:user_id])
          @locations = @user_org.locations
          @products = @user_org.products
          render :new  
        end
        format.json { render json: @inventory_projection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /inventory_projections/1
  # PATCH/PUT /inventory_projections/1.json
  def update
    respond_to do |format|
      if @inventory_projection.update(inventory_projection_params)
        format.html { redirect_to @inventory_projection, notice: 'Inventory projection was successfully updated.' }
        format.json { render :show, status: :ok, location: @inventory_projection }
      else
        format.html do
          @user_org = User.find(session[:user_id])
          @locations = @user_org.locations
          @products = @user_org.products
          render :edit 
        end
        format.json { render json: @inventory_projection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inventory_projections/1
  # DELETE /inventory_projections/1.json
  def destroy
    @inventory_projection.destroy
    respond_to do |format|
      format.html { redirect_to inventory_projections_url, notice: 'Inventory projection was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def matrix
    @user_org = User.find(session[:user_id]).organization
    @products = InventoryProjection.inventory_products @user_org
    @locations = InventoryProjection.inventory_locations @user_org
    @min_date = InventoryProjection.calculate(:minimum, :projected_for)
    @max_date = InventoryProjection.calculate(:maximum, :projected_for)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inventory_projection
      @inventory_projection = InventoryProjection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def inventory_projection_params
      params.require(:inventory_projection).permit(:location_name, :product_name, :location_id, :product_id, :projected_for, :available_quantity)
    end

    def inventory_projection_search_params
      params.require(:inventory_position_search).permit( :location_id, :product_id, :product_name, :product_code, :product_category_id)
    end

    def search_params(params)
      search_params = params.delete_if {|k,v| v.blank?}
      if search_params.key?("product_name")
        search_params["product_id"] =  Product.where(name: search_params["product_name"]).first.try(:id)
        search_params.delete("product_name")
      end
      if search_params.key?("product_code")
        search_params["product_id"] = Product.where(code: search_params["product_code"]).first.try(:id)
        search_params.delete("product_code")
      end
      search_params
    end

    def copy_inventory_file(inventory_file)
      File.open(Rails.root.join('public','inventory_uploads',inventory_file.original_filename),"wb") do |file|
        file.write(inventory_file.read)
      end
    end




end
