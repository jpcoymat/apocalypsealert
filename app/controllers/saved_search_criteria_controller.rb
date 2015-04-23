class SavedSearchCriteriaController < ApplicationController

  before_filter :authorize
  before_action :set_saved_search_criterium, only: [:show,:edit,:update,:destroy]
  
  def index
    @saved_search_criteria = SavedSearchCriterium.where(organization_id: User.find(session[:user_id]).organization.id)
    respond_to do |format|
      format.json {render json: @saved_search_criteria}
    end
  end

  def show
    respond_to do |format|
      format.json {render json: @saved_search_criterium}
    end
  end

  def edit
    
  end

  def create
    @saved_search_criterium = SavedSearchCriterium.new(saved_search_criterium_params)
    respond_to do |format|
      if @saved_search_criterium.save
        format.json { render :show, status: :created, location: @saved_search_criterium }
      else
        format.json { render json: @saved_search_criterium.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    respond_to do |format|
      logger.debug saved_search_criterium_params.to_s
      if @saved_search_criterium.update(saved_search_criterium_params)
        format.json { render json: @saved_search_criterium, status: :ok }
      else
        format.json { render json: @saved_search_criterium.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @saved_search_criterium.destroy
    respond_to do |format|
      format.json { head :no_content }
    end  
  end

  def new
    @saved_search_criterium = SavedSearchCriterium.new
  end

  private
  
    def set_saved_search_criterium
      @saved_search_criterium = SavedSearchCriterium.find(params[:id])
    end
    
    def saved_search_criterium_params
      all_search_params = params.require(:saved_search_criterium).fetch(:search_parameters, nil).try(:permit!)
      params.require(:saved_search_criterium).permit(:organization_id, :name, :page).merge(search_parameters: all_search_params )
    end

end