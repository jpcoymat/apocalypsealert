class MilestonesController < ApplicationController

  before_action :set_milestone, only: [:show, :edit, :update, :destroy]

  def file_upload
   render partial: "shared/file_upload", locals: {target_path: import_file_milestones_path}
  end

  def import_file
    milestone_file = params[:file]
    copy_milestone_file(milestone_file)
    Milestone.import(Rails.root.join('public','milestone_uploads').to_s + "/" + milestone_file.original_filename)
    redirect_to file_upload_milestones_path, notice: "File has been uploaded succesfully" 
  end

  def upload_complete
  end

  def lookup
  end

  # GET /milestones
  # GET /milestones.json
  def index
    @milestones = Milestone.all
  end

  # GET /milestones/1
  # GET /milestones/1.json
  def show
  end

  # GET /milestones/new
  def new
    @milestone = Milestone.new
  end

  # GET /milestones/1/edit
  def edit
  end

  # POST /milestones
  # POST /milestones.json
  def create
    @milestone = Milestone.new(milestone_params)

    respond_to do |format|
      if @milestone.save
        format.html { redirect_to @milestone, notice: 'Milestone was successfully created.' }
        format.json { render :show, status: :created, location: @milestone }
      else
        format.html { render :new }
        format.json { render json: @milestone.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /milestones/1
  # PATCH/PUT /milestones/1.json
  def update
    respond_to do |format|
      if @milestone.update(milestone_params)
        format.html { redirect_to @milestone, notice: 'Milestone was successfully updated.' }
        format.json { render :show, status: :ok, location: @milestone }
      else
        format.html { render :edit }
        format.json { render json: @milestone.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /milestones/1
  # DELETE /milestones/1.json
  def destroy
    @milestone.destroy
    respond_to do |format|
      format.html { redirect_to milestones_url, notice: 'Milestone was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_milestone
      @milestone = Milestone.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def milestone_params
      params.require(:milestone).permit(:associated_object_type, :associated_object_id, :milestone_type, :reason_code, :city, :country, :quantity, :customer_organization_id, :create_organization_id, :create_user_id)
    end

    def copy_milestone_file(milestone_file)
      File.open(Rails.root.join('public','milestone_uploads',milestone_file.original_filename),"wb") do |file|
        file.write(milestone_file.read)
      end
    end



end
