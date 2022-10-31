# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  banned             :boolean          default(FALSE)
#  current_sign_in_at :datetime
#  current_sign_in_ip :inet
#  dn                 :string
#  email              :string           default(""), not null
#  givenname          :string
#  last_sign_in_at    :datetime
#  last_sign_in_ip    :inet
#  mail               :string
#  moderator          :boolean
#  ou                 :string
#  sign_in_count      :integer          default(0), not null
#  sn                 :string
#  uid                :string
#  username           :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_users_on_email     (email)
#  index_users_on_username  (username)
#
class User < ApplicationRecord
  include EpiCas::DeviseHelper
  # has_many :listings, dependent: :nullify
  # has_many :messages, dependent: :delete_all
  # has_many :conversations, dependent: :delete_all
  
  has_many :buyer_transfer_request, class_name: 'Conversation',
    foreign_key: 'buyer_id'
  has_many :seller_transfer_request, class_name: 'Conversation',
    foreign_key: 'seller_id'
  
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  def get_display_information
    if self.email.nil? || self.email.empty?
      self.email = "None"
    end
    return {"id"=>self.id, "username"=>self.username, "fn"=>self.givenname, "sn"=>self.sn, "moderator"=>self.moderator, "email"=>self.email}
  end

  #===== Banning

  def ban!
    self.banned = true
    self.save
  end

  def unban!
    self.banned = false
    self.save
  end

  def isBanned?
    return self.banned
  end

  #===== Managing moderators

  def grant_moderator!
    self.moderator = true
    self.save
  end


  def revoke_moderator!
    self.moderator = false
    self.save
  end

  def isModerator?
    return self.moderator
  end


  #===== User lookup functions

  # gets all moderators and returns their display information in an array
  def self.show_moderators
    mods = User.where(moderator: true).order(:givenname)
    mods.present? ? (return generate_search_result mods) : (return nil)
  end

  # tries to search users matching the query (email, username or name)
  def self.search query
    if query.nil? || query.strip.empty?
      return nil
    end
    query = query.strip.downcase

    #try matching email
    email_r = /^[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+$/
    m = query.match email_r
    unless m.nil?
      matches = User.where(email: m[0])
      matches.present? ? (return generate_search_result matches) : (return nil)
    end

    #try matching username
    username_r = /^[a-z]+\d+[a-z]+$/
    m = query.match username_r
    unless m.nil?
      matches = User.where(username: m[0])
      return generate_search_result matches if matches.present?
    end

    #try matching name
    #First and Last Name
    name_r = /(?<fn>[a-zA-Z'-]+)\s+(?<sn>[a-zA-Z'-]+)/
    m = query.match name_r
    unless m.nil?
      matches = User.where(givenname: m[:fn], sn: m[:sn])
      matches = User.where('lower(givenname) = ? AND lower(sn) = ?', m[:fn], m[:sn])
      return generate_search_result matches if matches.present?
    end

    # 2. First or Last name
    single_word = /^[a-zA-Z'-]+$/
    m = query.match single_word
    unless m.nil?
      matches = User.where('lower(givenname) = ? OR lower(sn) = ?', m[0], m[0])
      return generate_search_result matches if matches.present?
    end

    return nil
  end

  # helper function for generating result for displaying
  def self.generate_search_result matches
    result = []
    matches.each {|usr| result.push usr.get_display_information}
    return result
  end

  # ===== Listing logic ===== 
  # Gets listings related to a single user.
  def get_users_listings()
    Listing.find_listing_by_user(self[:id]).order(created_at: :desc)
  end

  # Gets display information about all listings that the user can view
  def get_users_listings_info(own_profile)
    viewable_listings = get_users_listings()
    if !own_profile
      viewable_listings = viewable_listings.select {|listing| listing.has_approved_version?}
    end
    listing_details = []
    viewable_listings.each do |listing|
      listing_details.push(listing.generate_listing_hash)
    end
    return listing_details
  end

  # Formats the user's name
  def show_user
    return givenname + ' ' + sn[0] + '.'
  end

  # ===== Deleting Users =====
  def delete!()
    # Wipe all personal information.
    # self.last_sign_in_ip = None
    self.dn = ""
    self.email = ""
    self.givenname = "[Deleted User]"
    self.mail = ""
    self.ou = ""
    self.sn = ""
    # self.username = ""
    # self.uid = ""

    # Commit changes
    save!

    # Delete all associated listings.
    get_users_listings().each do |listing|
      listing.delete_listing()
    end
  end
end
