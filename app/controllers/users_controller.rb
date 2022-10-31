class UsersController < ApplicationController
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html { redirect_to main_app.root_url, notice: exception.message }
    end
  end

  before_action :set_user, except: [:search, :revoke_moderator, :grant_moderator, :get_moderators, :destroy]

  def show
    @user_listings = @user.get_users_listings_info(can?(:manage, @user))
  end

  
  def get_moderators
    authorize! :get_moderators, User
    mods = User.show_moderators
    respond_to {|format| format.json {render status: 200, json: {"success" => true, "matches" => mods}}}
  end


  def search
    authorize! :search, User
    result = User.search params[:query]
    respond_to {|format| format.json {render status: 200, json: {"success" => true, "matches" => result}}}
  end


  def grant_moderator
    authorize! :manage_moderators, User
    if params[:id].nil?
      respond_to {|format| format.json {render status: 400, json: {"success" => false, "reason" => "No ID given"}}}
      return
    end
    u = User.find_by(id: params[:id])
    if u.nil? || u.isModerator?
      respond_to {|format| format.json {render status: 400, json: {"success" => false, "reason" => "User doesn't exist or already a moderator"}}}
    else
      u.grant_moderator!
      respond_to {|format| format.json {render status: 200, json: {"success" => true, "id" => params[:id]}}}
    end
  end


  def revoke_moderator
    authorize! :manage_moderators, User
    if params[:id].nil?
      respond_to {|format| format.json {render status: 400, json: {"success" => false, "reason" => "No ID given"}}}
      return
    end
    u = User.find_by(id: params[:id])
    if u.nil? || !u.isModerator?
      respond_to {|format| format.json {render status: 400, json: {"success" => false, "reason" => "User doesn't exist or already not a moderator"}}}
    else
      u.revoke_moderator!
      respond_to {|format| format.json {render status: 200, json: {"success" => true, "id" => params[:id]}}}
    end
  end

  
  def ban_user
    authorize! :ban, User
    if params[:id].nil?
      respond_to {|format| format.json {render status: 400, json: {"success" => false, "reason" => "No ID given"}}}
      return
    end
    u = User.find_by(id: params[:id])
    if u.nil? || u.isBanned?
      respond_to {|format| format.json {render status: 400, json: {"success" => false, "reason" => "User doesn't exist or already banned"}}}
    else
      u.ban!
      respond_to {|format| format.json {render status: 200, json: {"success" => true, "id" => params[:id]}}}
    end
  end

  
  def unban_user
    authorize! :unban, User
    if params[:id].nil?
      respond_to {|format| format.json {render status: 400, json: {"success" => false, "reason" => "No ID given"}}}
      return
    end
    u = User.find_by(id: params[:id])
    if u.nil? || !u.isBanned?
      respond_to {|format| format.json {render status: 400, json: {"success" => false, "reason" => "User doesn't exist or already not banned"}}}
    else
      u.unban!
      respond_to {|format| format.json {render status: 200, json: {"success" => true, "id" => params[:id]}}}
    end
  end

  def destroy
    sign_out_and_redirect(current_user)
    User.find_by(id: params[:id]).delete!
  end

  private
    def set_user
      @user = User.find(params[:id])
    end
end