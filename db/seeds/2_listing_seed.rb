require_relative "../seeds_helper.rb"

def create_listing(params)
  # Select user and check if they exist.
  user = User.where(username: params["user"]).first
  if user.nil?
    return false
  end

  # Create listing model.
  listing = Listing.where(created_at: params["created_at"],
                          updated_at: params["updated_at"],
                          user: user).first_or_create!

  # Add all the listing content objects.
  params["listing_content_versions"].each do |content_params|
    if !create_listing_content(content_params, listing) then return false end
  end
end

def create_listing_content(params, listing)
  category = Category.where(name: params["category"]).first

  content_params = {
    title: params["title"],
    description: params["description"],
    category: category,
    price: params["price"],
    location: params["location"],
    post_code: params["post_code"],
    delivery_options: params["delivery_options"],
    condition: params["condition"],
    payment_options: params["payment_options"],
    listing: listing,
    approved: params["approved"],
    created_at: params["created_at"],
    updated_at: params["updated_at"],
  }
  listing_content = ListingContent.where(title: content_params[:title]).first_or_create!(content_params)
  listing_content.update(content_params)
  if ListingContent.where(id: listing_content.id).first.nil? then return false end

  # Adding images to the seeds.
  listing_content.images.purge
  if !Rails.env.development?
    params["images"].each do |file|
      listing_content.images.attach(io: File.open(file), filename: file.split("/")[-1])
    end
  end
end

approved_listings = read_YAML_seed("approved_listings")

approved_listings.each do |listing_title, listing|
  listing_content = listing["listing_content_versions"][0]
  listing_content["approved"] = true
  listing_content["created_at"] = listing["created_at"]
  listing_content["updated_at"] = listing["updated_at"]
end

# Colate all the parameters and add them all to the db.
listings_params = []

listings_params.push(*approved_listings)

listings_params.each do |name, params|
  create_listing(params)
end
