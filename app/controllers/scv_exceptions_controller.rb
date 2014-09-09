class ScvExceptionsController < ApplicationController
  before_filter :authorize
  before_action :set_scv_exception, only: [:show, :edit, :update, :destroy]


  def file_upload
   render partial: "shared/file_upload", locals: {target_path: import_file_scv_exceptions_path}
  end

  def import_file
    scv_exceptions_file = params[:file]
    copy_scv_exceptions_file(scv_exceptions_file)
    ScvException.import(Rails.root.join('public','scv_exception_uploads').to_s + "/" + scv_exceptions_file.original_filename)
    redirect_to scv_exceptions_path
  end




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
      params.require(:scv_exception).permit(:exception_type, :priority, :status, :affected_object_type, :affected_object_reference_number, :affected_object_quantity_type, :affected_object_quantity, :affected_object_date_type, :affected_object_date, :cause_object_type, :cause_object_reference_number, :cause_object_quantity_type, :cause_object_quantity, :cause_object_date_type, :cause_object_date, :affected_object_id, :cause_object_id )
    end

    def copy_scv_exceptions_file(scv_exceptions_file)
      File.open(Rails.root.join('public','scv_exception_uploads',scv_exceptions_file.original_filename),"wb") do |file|
        file.write(scv_exceptions_file.read)
      end
    end


end
