class ModeratorController < ApplicationController
  
  def index
    @current_user_id =  current_user[:id]

    redirect_to root_path, notice: "You are not authorized" unless can?(:review_list, Listing)
    @categories = Category.get_all.order(:name)
    @listings_to_moderate = Listing.select_pending.size
    @all_listings = Listing.get_all_listing_hashes
  end
end