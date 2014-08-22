class ShipmentLinesController < ApplicationController
  before_action :set_shipment_line, only: [:show, :edit, :update, :destroy]

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
    @shipment_line = ShipmentLine.new
  end

  # GET /shipment_lines/1/edit
  def edit
  end

  # POST /shipment_lines
  # POST /shipment_lines.json
  def create
    @shipment_line = ShipmentLine.new(shipment_line_params)

    respond_to do |format|
      if @shipment_line.save
        format.html { redirect_to @shipment_line, notice: 'Shipment line was successfully created.' }
        format.json { render :show, status: :created, location: @shipment_line }
      else
        format.html { render :new }
        format.json { render json: @shipment_line.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shipment_lines/1
  # PATCH/PUT /shipment_lines/1.json
  def update
    respond_to do |format|
      if @shipment_line.update(shipment_line_params)
        format.html { redirect_to @shipment_line, notice: 'Shipment line was successfully updated.' }
        format.json { render :show, status: :ok, location: @shipment_line }
      else
        format.html { render :edit }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shipment_line
      @shipment_line = ShipmentLine.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shipment_line_params
      params.require(:shipment_line).permit(:shipment_line_number, :quantity, :eta, :etd, :origin_location_id, :destination_location_id, :order_line_id)
    end
end
