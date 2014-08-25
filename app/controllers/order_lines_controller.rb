class OrderLinesController < ApplicationController
  before_filter :authorize
  before_action :set_order_line, only: [:show, :edit, :update, :destroy]

  # GET /order_lines
  # GET /order_lines.json

  def lookup
    @user = User.find(session[:user_id])
    @user_org = @user.organization
    @products = @user_org.products
    @locations = @user_org.locations
    @all_order_lines = @user_org.order_lines
    @organizations = Organization.all
    if request.post?
      @order_lines = @user_org.order_lines.where(search_params)
      respond_to do |format|
        format.html
        format.json {render json: @order_lines}
      end
    end
  end

  def csv_upload
  end


  def index
    @user = User.find(session[:user_id])
    @order_lines = OrderLine.where(organization_id: @user.organization_id).all
  end

  # GET /order_lines/1
  # GET /order_lines/1.json
  def show
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
      format.html { redirect_to lookup_order_lines_url, notice: 'Order line was successfully destroyed.' }
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
      params.require(:order_line).permit(:product_name, :order_line_number, :quantity, :eta, :etd, :origin_location_id, :destination_location_id, :supplier_organization_id, :customer_organization_id)
    end

    def search_params
      search_params = order_line_params.delete_if {|k,v| v.blank?}
      if search_params.key?("product_name")
        search_params["product_id"] =  Product.where(name: search_params["product_name"]).first.id
        search_params.delete("product_name")
      end
      search_params
    end



end
