class PagesController < ApplicationController

  skip_authorization_check

  def home
    @current_nav_identifier = :home
    
  end

  def show
    render template: "pages/#{params[:page]}"
  end

end
