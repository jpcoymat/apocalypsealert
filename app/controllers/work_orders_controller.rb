class WorkOrdersController < ApplicationController

  before_action :set_work_order, only: [:show, :edit, :update, :destroy]
  before_filter :authorize


  def lookup
    @user = User.find(session[:user_id])
    @user_org = @user.organization
    @products = @user_org.products
    @locations = @user_org.locations
    @all_work_orders = @user_org.work_orders
    if request.post?
      @work_orders = @all_work_orders.where(search_params)
      respond_to do |format|
        format.html
        format.json {render json: @work_orders}
      end
    end
  end

  def file_upload
    render partial: "shared/file_upload", locals: {target_path: import_file_work_orders_path}
  end

  def import_file
    work_order_file = params[:file]
    copy_work_order_file(work_order_file)
    WorkOrder.import(Rails.root.join('public','work_order_uploads').to_s + "/" + work_order_file.original_filename)
    redirect_to lookup_work_orders_path
  end
  # GET /work_orders
  # GET /work_orders.json
  def index
    @work_orders = WorkOrder.all
  end

  # GET /work_orders/1
  # GET /work_orders/1.json
  def show
  end

  # GET /work_orders/new
  def new
    @work_order = WorkOrder.new
    @user = User.find(session[:user_id])
    @user_org = @user.organization
    @products = @user_org.products
    @locations = @user_org.locations
  end

  # GET /work_orders/1/edit
  def edit
    @user = User.find(session[:user_id])
    @user_org = @user.organization
    @products = @user_org.products
    @locations = @user_org.locations
  end

  # POST /work_orders
  # POST /work_orders.json
  def create
    @work_order = WorkOrder.new(work_order_params)

    respond_to do |format|
      if @work_order.save
        format.html { redirect_to @work_order, notice: 'Work order was successfully created.' }
        format.json { render :show, status: :created, location: @work_order }
      else
        format.html do 
          @user = User.find(session[:user_id])
          @user_org = @user.organization
          @products = @user_org.products
          @locations = @user_org.locations
          render :new 
        end
        format.json { render json: @work_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /work_orders/1
  # PATCH/PUT /work_orders/1.json
  def update
    respond_to do |format|
      if @work_order.update(work_order_params)
        format.html { redirect_to @work_order, notice: 'Work order was successfully updated.' }
        format.json { render :show, status: :ok, location: @work_order }
      else
        format.html do 
          @user = User.find(session[:user_id])
          @user_org = @user.organization
          @products = @user_org.products
          @locations = @user_org.locations
          render :edit 
        end
        format.json { render json: @work_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /work_orders/1
  # DELETE /work_orders/1.json
  def destroy
    @work_order.destroy
    respond_to do |format|
      format.html { redirect_to work_orders_url, notice: 'Work order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_work_order
      @work_order = WorkOrder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def work_order_params
      params.require(:work_order).permit(:work_order_number, :product_id, :location_id, :production_date, :quantity, :organization_id, :is_active, :product_name)
    end

    def search_params
      search_params = work_order_params.delete_if {|k,v| v.blank?}
      if search_params.key?("product_name")
        search_params["product_id"] =  Product.where(name: search_params["product_name"]).first.id
        search_params.delete("product_name")
      end
      search_params
    end

    def copy_work_order_file(work_order_file)
      File.open(Rails.root.join('public','work_order_uploads',work_order_file.original_filename),"wb") do |file|
        file.write(work_order_file.read)
      end
    end

end
