SHELF_ITEM_COUNT = 6

class ListingsController < ApplicationController

  before_action :find_listing, only: [:edit, :show, :destroy, :update, :delete_image]
  before_action :get_categories, except: [:index, :destroy, :show, :review_list]

  def index
    #Listing selection
    new_listings = Listing.newest(SHELF_ITEM_COUNT)
    free_listings = Listing.newest_free(SHELF_ITEM_COUNT, new_listings)
    exchange_listings = Listing.newest_exchanges(SHELF_ITEM_COUNT, new_listings + free_listings)

    # Shelf Generation
    @shelves = {}
    @shelves["new_listings"] = {content: new_listings, title: "Newest Items", class: "new-listings"}
    @shelves["free_listings"] = {content: free_listings, title: "Free Items", class: "free-listings"}
    @shelves["swap_listings"] = {content: exchange_listings, title: "Swappable Items", class: "swap-listings"}
  end

  def show
    redirect_to root_path, notice: "This listing is not available for viewing" unless can?(:read, @listing)
    @listing_content = @listing.listing_content(approved: true)
    if @listing_content.nil?
      @listing_content = @listing.listing_content
    end

    @urls = @listing_content.image_urls

    @payments = @listing_content.print_payment_options
    @deliveries = @listing_content.print_delivery_options
    @condition = @listing_content.print_condition

    @modified = @listing_content.print_last_modified
    @pending = !@listing.fully_approved?
  end

  def edit
    @mod_editing = !can?(:update, @listing) && current_user.moderator
    redirect_to root_path, notice: "You can't edit this listing" unless (can?(:update, @listing) || @mod_editing)
    @deleted_image_ids = params[:image_ids]
    if @deleted_image_ids.nil?
      @deleted_image_ids = []
    end
  end

  def new
  end

  def create
    listing = Listing.create(user: current_user)
    listing_content = ListingContent.new()
    new_params = listing_params
    selected_category = Category.find_by(name: new_params.delete(:category))
    if !selected_category.nil?
      new_params[:category_id] = selected_category.id
    end
    new_params[:listing_id] = listing.id

    if listing_content.update(new_params)
      redirect_to listing, notice: 'Listing was successfully created.'
    else
      redirect_to new_listing_path, notice: "Couldn't create listing, some of the mandatory options have invalid or empty inputs"
    end

  end

  def update
    if params[:commit].nil?
      ListingContent.where(listing_id: params[:id]).order(created_at: :desc).first.update(approved: true)
      redirect_to listing_review_path, notice: 'Listing was accepted'
    else
      collate_images
      new_listing = ListingContent.new(listing_id: @listing.id)
      if new_listing.update(edit_listing_params)
        redirect_to @listing, notice: 'Listing edition successful, awaiting approval by moderators'
      else
        redirect_to edit_listing_path, notice: 'Edition unsuccessful, some of the non-optional details were blank or invalid'
      end
    end
  end

  def delete_image
    redirect_to edit_listing_path(@listing, image_ids: params[:image_ids].split("/")), notice: 'Image was removed from the listing'
  end

  def destroy
    @listing.delete_listing
    if params[:commit] == "reject"
      redirect_to listing_review_path, notice: 'Listing was rejected and deleted'
    else
      redirect_to root_path, notice: 'Listing was deleted'
    end

  end

  # Get for moderation queue
  def review_list
    redirect_to root_path, notice: "You are not authorized" unless can?(:review_list, Listing)
    @listings_for_approval = Listing.select_pending
    if @listings_for_approval.size != 0
      id = params[:clicked_listing_id]
      if id.nil?
        @current_listing = @listings_for_approval[0]
      else
        @current_listing = Listing.find_listing(id)
      end
      @current_content = @current_listing.listing_content
      @urls = @current_content.image_urls()
    end
  end

  def search
    non_advanced_params = ["title", "category", "button"]
    @is_advanced_search = false
    search_listing_params.each do |param|
      logger.info param
      if !non_advanced_params.include? param[0] then @is_advanced_search = true end
    end
    @search_listings = Listing.search(true, search_listing_params)  
  end

  def search_listing
    if params[:title].strip != ""
      results = Listing.search(true, params)
      result = []
      results.each do |listing|
        result.push(listing.listing_content(approved: true))
      end
      respond_to {|format| format.json {render status: 200, json: {"success" => true, "matches" => result}}}
    else
      respond_to {|format| format.json {render status: 200, json: {"success" => true, "matches" => []}}}
    end
  end

  private
    def listing_params
      params.require(:listing).permit(:title, :description, :category, :price, :location, :condition, :post_code, :terms, delivery_options: [], payment_options: [], images: [])
    end

    def search_listing_params
      params.permit(:title, :category, :button, :lower_bound_price, :upper_bound_price, :commit, location_options: [], payment_options: [], delivery_options: [], condition_options: [])
    end

    def edit_listing_params 
      params.require(:listing_content).permit(:title, :description, :category_id, :price, :location, :condition, :images_to_delete, :post_code, delivery_options: [], payment_options: [], images: [], new_images: [])
    end

    def find_listing
      @listing = Listing.find_listing(params[:id])
      @listing_content = @listing.listing_content
    end

    def get_categories
      @categories = []
      all_categories = Category.get_all.order(:name)
      all_categories.each do |category|
        @categories.push(category.name)
      end
    end
    
    def collate_images
      if !params[:listing_content][:images_to_delete].nil?
        removed_images = params[:listing_content].delete(:images_to_delete).split(" ")
        if !params[:listing_content][:images].nil?
          params[:listing_content][:images].delete_if {|image| removed_images.include? image}
        end
      end
      if params[:listing_content][:new_images].nil?
        params[:listing_content].delete(:new_images)
      else
        new_images = params[:listing_content].delete(:new_images)
        if params[:listing_content][:images].nil?
          params[:listing_content][:images] = new_images
        else
          new_images.each do |image|
            params[:listing_content][:images].push(image)
          end
        end
      end
    end
end
