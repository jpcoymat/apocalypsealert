class LocationGroupsController < ApplicationController

  before_filter :authorize
  before_action :set_location_group, only: [:show, :edit, :update, :destroy]
  before_action :set_user

  # GET /location_groups
  # GET /location_groups.json
  def index
    @location_groups = LocationGroup.all
  end

  # GET /location_groups/1
  # GET /location_groups/1.json
  def show
  end

  # GET /location_groups/new
  def new
    @location_group = LocationGroup.new
  end

  # GET /location_groups/1/edit
  def edit
  end

  # POST /location_groups
  # POST /location_groups.json
  def create
    @location_group = LocationGroup.new(location_group_params)

    respond_to do |format|
      if @location_group.save
        format.html { redirect_to @location_group, notice: 'Location group was successfully created.' }
        format.json { render :show, status: :created, location: @location_group }
      else
        format.html { render :new }
        format.json { render json: @location_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /location_groups/1
  # PATCH/PUT /location_groups/1.json
  def update
    respond_to do |format|
      if @location_group.update(location_group_params)
        format.html { redirect_to @location_group, notice: 'Location group was successfully updated.' }
        format.json { render :show, status: :ok, location: @location_group }
      else
        format.html { render :edit }
        format.json { render json: @location_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /location_groups/1
  # DELETE /location_groups/1.json
  def destroy
    @location_group.destroy
    respond_to do |format|
      format.html { redirect_to location_groups_url, notice: 'Location group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location_group
      @location_group = LocationGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_group_params
      params.require(:location_group).permit(:code, :name, :organization_id)
    end

    def set_user
      @user = User.find(session[:user_id])
    end

end
