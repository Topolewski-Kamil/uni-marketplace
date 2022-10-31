# == Schema Information
#
# Table name: listing_contents
#
#  id               :bigint           not null, primary key
#  approved         :boolean          default(FALSE)
#  condition        :string
#  delivery_options :string
#  description      :text
#  location         :string
#  payment_options  :string
#  post_code        :string
#  price            :float
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  category_id      :integer
#  listing_id       :integer
#
class ListingContent < ApplicationRecord
  has_many_attached :images
  belongs_to :category
  belongs_to :listing

  validates :title, :description, :price, :location, :category, :delivery_options, presence: true
  validates :title, length: {maximum: 250}
  validates :description, length: {maximum: 2000}
  validates :price, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 10000}
  validates :terms, acceptance: true
  validates :images, length: {maximum: 5}
  validate :file_format?
  validate :file_size?

  # validates_size_of :images, maximum: 1.megabytes, message: "should be less than 1MB"

  CONDITIONS = ["New","Slightly Used","Well Used"]
  PAYMENT_OPTIONS = ["Cash","Bank Transfer","Paypal","Swap"]
  DELIVERY_OPTIONS = ["Postal Delivery","Collection","In Person Delivery"]
  LOCATION_OPTIONS = ["Sheffield","UK","International"]
  PLACEHOLDER_IMAGE = "/image-placeholder.png"
  CONTENT_DELETION = {title: '<Removed>', description: '<Removed>', location: '<Removed>', approved: false}

  MAX_UPLOAD_SIZE = 500

  include Rails.application.routes.url_helpers
  include ActionView::Helpers::NumberHelper

  def self.display_options(options_array)
    if options_array.nil?
      return 'None specified'
    else
      return options_array.gsub(/[^0-9A-Za-z, ]/, '')
    end
  end

  def display_price
    new_price = price
    if new_price == 0
      return "Free"
    end
    new_price = number_to_currency(new_price)
  end

  def listing_url
    if images.attached?
      return rails_blob_path(images.blobs.first, disposition: "image", only_path: true)
    else
      return PLACEHOLDER_IMAGE
    end
  end

  def image_urls
    urls = []
    if images.attached?
      images.blobs.each do |blob|
        urls.push(rails_blob_path(blob, disposition: "image", only_path: true))
      end
    else
      urls.push(PLACEHOLDER_IMAGE)
    end
    return urls
  end

  def print_payment_options
    return ListingContent.display_options(payment_options)
  end

  def print_condition
    return ListingContent.display_options(condition)
  end

  def print_delivery_options
    return ListingContent.display_options(delivery_options)
  end

  def print_last_modified
    return created_at.strftime("%d/%m/%Y")
  end

  def delete_contents
    delete_older_versions
    delete_all_images
    update(CONTENT_DELETION)
  end

  def delete_older_versions
    old_versions = ListingContent.where(listing_id: self[:listing_id]).where.not(id: self[:id])
    old_versions.each do |version|
      version.delete_all_images
      version.destroy
    end
  end

  def delete_all_images
    images.each do |image|
      ActiveStorage::Attachment.find(image.id).purge
    end
    self.images.attach()
  end

  def file_format?
    self.images.each do |image|
      ext = File.extname(image.filename.to_s)
      unless %w( .jpg .jpeg .png ).include? ext.downcase
        errors[:document] << "Invalid file format."
      end
    end
  end

  def file_size?
    file_size = 0
    self.images.each do |image|
      file_size += image.byte_size / 1024
    end
    if file_size > MAX_UPLOAD_SIZE
      errors[:document] << "Maximum upload size exceeded."
    end
  end

  def get_delivery_options
    if self.delivery_options.nil?
      return "None"
    else
      return self.delivery_options
    end
  end

  def get_condition_options
    if self.condition.nil?
      return "None"
    else
      return self.condition
    end
  end

  def get_payment_options
    if self.payment_options.nil?
      return "None"
    else
      return self.payment_options
    end
  end
  
  # ===== Filtering Functions =====
  def match_filter?(title= nil, category= nil, payment_options= nil, delivery_options= nil, condition= nil, price_lb=nil, price_ub=nil, location_options= nil)
    filters = []

    filters.push(self.title_contains_string?(title)) # Title
    filters.push(self.is_category?(category)) # Category
    filters.push(self.has_payment_options?(payment_options)) # Payment
    filters.push(self.has_delivery_options?(delivery_options)) # Delivery
    filters.push(self.has_condition_options?(condition)) # Condition
    filters.push(self.price_in_range?(price_lb, price_ub)) # Price
    filters.push(self.has_location_options?(location_options)) # Location


    return filters.all?
  end

  def title_contains_string?(string)
    if string.nil? || string.empty? then
      return true
    else 
      self.title.downcase.include? string.downcase
    end
  end

  def is_category?(category)
    if category.nil? || category.empty?
      return true
    else
      self.category_id == category.to_i
    end
  end

  def price_in_range?(lb, ub)
    if !(lb.nil? || lb.empty?) && self.price < lb.to_i
      return false
    elsif !(ub.nil? || ub.empty?) && self.price > ub.to_i
      return false
    end
    return true
  end

  def has_payment_options?(options)
    ListingContent.contains_elements_in_string?(self.payment_options, options)
  end

  def has_delivery_options?(options)
    ListingContent.contains_elements_in_string?(self.delivery_options, options)
  end

  def has_condition_options?(options)
    ListingContent.contains_elements_in_string?(self.condition, options)
  end

  def has_location_options?(options)
    ListingContent.contains_elements_in_string?(self.location, options)
  end
  # ===== Static Functions =====

  # Check if option
  def self.contains_elements_in_string?(string, arr)
    if arr.nil? then return true end
    arr.each do |elem|
      if string.include?(elem) then return true end
    end
    return false
  end
end
