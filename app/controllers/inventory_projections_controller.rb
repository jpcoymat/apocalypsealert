class InventoryProjectionsController < ApplicationController
  before_action :set_inventory_projection, only: [:show, :edit, :update, :destroy]

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
  end

  # GET /inventory_projections/1/edit
  def edit
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
        format.html { render :new }
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
        format.html { render :edit }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inventory_projection
      @inventory_projection = InventoryProjection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def inventory_projection_params
      params.require(:inventory_projection).permit(:location_id, :product_id, :projected_for, :available_quantity)
    end
end
