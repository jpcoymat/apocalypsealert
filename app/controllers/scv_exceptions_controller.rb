class ScvExceptionsController < ApplicationController
  before_action :set_scv_exception, only: [:show, :edit, :update, :destroy]

  # GET /scv_exceptions
  # GET /scv_exceptions.json
  def index
    @scv_exceptions = ScvException.all
  end

  # GET /scv_exceptions/1
  # GET /scv_exceptions/1.json
  def show
  end

  # GET /scv_exceptions/new
  def new
    @scv_exception = ScvException.new
  end

  # GET /scv_exceptions/1/edit
  def edit
  end

  # POST /scv_exceptions
  # POST /scv_exceptions.json
  def create
    @scv_exception = ScvException.new(scv_exception_params)

    respond_to do |format|
      if @scv_exception.save
        format.html { redirect_to @scv_exception, notice: 'Scv exception was successfully created.' }
        format.json { render :show, status: :created, location: @scv_exception }
      else
        format.html { render :new }
        format.json { render json: @scv_exception.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /scv_exceptions/1
  # PATCH/PUT /scv_exceptions/1.json
  def update
    respond_to do |format|
      if @scv_exception.update(scv_exception_params)
        format.html { redirect_to @scv_exception, notice: 'Scv exception was successfully updated.' }
        format.json { render :show, status: :ok, location: @scv_exception }
      else
        format.html { render :edit }
        format.json { render json: @scv_exception.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scv_exceptions/1
  # DELETE /scv_exceptions/1.json
  def destroy
    @scv_exception.destroy
    respond_to do |format|
      format.html { redirect_to scv_exceptions_url, notice: 'Scv exception was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scv_exception
      @scv_exception = ScvException.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scv_exception_params
      params.require(:scv_exception).permit(:type, :priority, :status)
    end
end
