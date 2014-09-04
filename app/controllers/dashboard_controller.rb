class DashboardController < ApplicationController

  before_filter :authorize


  def index
    @user_org = User.find(session[:user_id]).organization
    @locations = @user_org.locations
  end


end
