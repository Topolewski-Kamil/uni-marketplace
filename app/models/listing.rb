# == Schema Information
#
# Table name: listings
#
#  id         :bigint           not null, primary key
#  archived   :boolean          default(FALSE)
#  deleted    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_listings_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Listing < ApplicationRecord
  belongs_to :user

  # ===== Static Functions =====
  # Returns all approved listings.
  def self.select_approved_listings
    return Listing.select { |listing| listing.has_approved_version? }
  end

  # Select the last x listings based off date created.
  def self.newest(count)
    ordered_listings = Listing.order(:created_at).select do |listing| 
      listing.has_approved_version?
    end
      
    return ordered_listings.last(count).reverse
  end

  def self.newest_free(count, mask)
    Listing.select{|listing| listing.has_approved_version? and listing.listing_content(approved: true).price == 0.0 and (!mask.include? listing)}.last(count).reverse()
  end

  def self.newest_exchanges(count, mask)
    Listing.select{|listing| listing.has_approved_version? and listing.listing_content(approved: true).get_payment_options().include? "Swap" and (!mask.include? listing)}.last(count).reverse()
  end

  # Select based on search query
  def self.search(only_approved, params)
    listings = Listing.select do |listing|
      listing_content = listing.listing_content(only_approved)
      if listing_content.nil? then next false end # If no content is found then false.
      filters = [] # Array of booleans for all the filters listed here.

      filters.push(!only_approved || listing.has_approved_version?) # Matches Approval Status.
      filters.push(listing_content.match_filter?(
        title= params[:title],
        category= params[:category],
        payment_options= params[:payment_options],
        delivery_options= params[:delivery_options],
        condition= params[:condition_options],
        price_lb= params[:lower_bound_price],
        price_ub= params[:upper_bound_price],
        location_options= params[:location_options]
      )) # Content spesific filtering.

      next filters.all?
    end

    listings.reverse() # Reverse order.

    return listings
  end

  def self.select_listings_by_category_id(category_id)
    Listing.select{|listing| (listing.listing_content.category_id == category_id)}
  end

  # Returns the listing indentified by the given id
  def self.find_listing(id)
    Listing.find(id)
  end
  
  def self.find_listing_by_user(id)
    Listing.where(user_id: id, deleted: false)
  end
  
  # Selects all listings that should be on the moderation queue
  def self.select_pending
    Listing.select {|listing| !listing.deleted && !listing.fully_approved?}
  end

  # Returns a hash for each approved listing
  def self.get_all_listing_hashes
    listings = select_approved_listings
    hashes = []
    listings.each do |listing|
      hashes.push(listing.generate_listing_hash)
    end
    return hashes
  end
  
  # Deletes listing
  def delete_listing
    listing_content.delete_contents
    update(deleted: true)
  end

  # Generates a hash for the specified listing
  def generate_listing_hash
    content = listing_content(approved: true)
    if content.nil?
      content = listing_content
    end
    return {listing: self, content: content, pending: !fully_approved?}
  end

  # ===== Approval Logic =====
  # Check if listing's latest version is approved.
  def fully_approved?
    last_content = ListingContent.where(listing_id: self[:id]).last
    if last_content.nil? then return false end
    return last_content.approved
  end

  # Check if a listing has any approved versions.
  def has_approved_version?
    ListingContent.where(listing_id: self[:id], approved: true).size > 0
  end

  # ===== Listing Content Logic =====
  def listing_content(approved = false)
    listings = nil
    if approved
      listings = ListingContent.where(listing_id: self[:id], approved: true)
    else
      listings = ListingContent.where(listing_id: self[:id])
    end
    return listings.order(:created_at).last
  end

  def get_all_listing_contents
    ListingContent.where(listing_id: self[:id])
  end

  # ===== Ability Logic =====
  def user_can_read?(user)
    return !deleted && ((has_approved_version?) || (!has_approved_version? && (self[:user_id] == user.id)))
  end

  def user_can_update?(user)
    user_id == user.id
  end
end
