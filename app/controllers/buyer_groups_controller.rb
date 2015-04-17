class BuyerGroupsController < ApplicationController
  before_action :set_buyer_group, only: [:show, :edit, :update, :destroy]

  # GET /buyer_groups
  # GET /buyer_groups.json
  def index
    @buyer_groups = BuyerGroup.all
  end

  # GET /buyer_groups/1
  # GET /buyer_groups/1.json
  def show
  end

  # GET /buyer_groups/new
  def new
    @buyer_group = BuyerGroup.new
  end

  # GET /buyer_groups/1/edit
  def edit
  end

  # POST /buyer_groups
  # POST /buyer_groups.json
  def create
    @buyer_group = BuyerGroup.new(buyer_group_params)

    respond_to do |format|
      if @buyer_group.save
        format.html { redirect_to @buyer_group, notice: 'Buyer group was successfully created.' }
        format.json { render :show, status: :created, location: @buyer_group }
      else
        format.html { render :new }
        format.json { render json: @buyer_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /buyer_groups/1
  # PATCH/PUT /buyer_groups/1.json
  def update
    respond_to do |format|
      if @buyer_group.update(buyer_group_params)
        format.html { redirect_to @buyer_group, notice: 'Buyer group was successfully updated.' }
        format.json { render :show, status: :ok, location: @buyer_group }
      else
        format.html { render :edit }
        format.json { render json: @buyer_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /buyer_groups/1
  # DELETE /buyer_groups/1.json
  def destroy
    @buyer_group.destroy
    respond_to do |format|
      format.html { redirect_to buyer_groups_url, notice: 'Buyer group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_buyer_group
      @buyer_group = BuyerGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def buyer_group_params
      params.require(:buyer_group).permit(:organization_id, :name, :description)
    end
end
