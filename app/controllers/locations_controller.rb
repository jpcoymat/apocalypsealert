class LocationsController < ApplicationController
  
  before_filter :authorize
  before_action :set_location, only: [:show, :edit, :update, :destroy]
  before_filter :set_user

  # GET /locations
  # GET /locations.json
  def index
    @locations = Location.all
  end

  # GET /locations/1
  # GET /locations/1.json
  def show
  end

  # GET /locations/new
  def new
    @location = Location.new
    @location_groups = @user.organization.location_groups
  end

  # GET /locations/1/edit
  def edit
    @location_groups = @user.organization.location_groups 
  end

  # POST /locations
  # POST /locations.json
  def create
    @location = Location.new(location_params)

    respond_to do |format|
      if @location.save
        format.html { redirect_to locations_path, notice: 'Location was successfully created.' }
        format.json { render :show, status: :created, location: @location }
      else
        format.html do 
          @location_groups = @user.organization.location_groups
          render :new 
        end
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /locations/1
  # PATCH/PUT /locations/1.json
  def update
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to locations_path, notice: 'Location was successfully updated.' }
        format.json { render :show, status: :ok, location: @location }
      else
        format.html do 
          @location_groups = @user.organization.location_groups
          render :edit 
        end
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  def destroy
    @location.destroy
    respond_to do |format|
      format.html { redirect_to locations_url, notice: 'Location was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_params
      params.require(:location).permit(:name, :code, :address, :city, :state_providence, :country, :postal_code, :latitude, :longitude, :organization_id, :location_group_id)
    end

    def set_user
      @user = User.find(session[:user_id])
    end
end
