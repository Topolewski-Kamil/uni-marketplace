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
require "rails_helper"

RSpec.describe User, type: :model do
  describe ListingContent do
    describe '#delete_all_images' do
      it 'Deletes all images passed in by their ids' do
        listing_images = {images: [ActionDispatch::Http::UploadedFile.new({filename: "test-image-1.jpg", type: "image/jpeg", tempfile: Tempfile.new('listing_spec-test-image-1'), head: 'test_headers'}),ActionDispatch::Http::UploadedFile.new({filename: "test-image-2.png", type: "image/png", tempfile: Tempfile.new('listing_spec-test-image-2'), head: 'test_headers2'})]}
        listing = FactoryBot.create :listing_content, category: (FactoryBot.create :category), listing: (FactoryBot.create :listing, user: (FactoryBot.create :user))
        listing.images.attach(listing_images[:images])
        listing.delete_all_images
        expect(ActiveStorage::Attachment.all.pluck(:id)).to eq []
      end
    end

    describe '#display_options' do
      it 'Produces default output when options array is nil (no options chosen)' do
        listing = ListingContent.new()
        expect(ListingContent.display_options(listing.delivery_options)).to eq 'None specified'
      end

      it "Produces readable output for options array with a singular element" do
        listing = ListingContent.new(delivery_options: '["Postal Delivery"]')
        expect(ListingContent.display_options(listing.delivery_options)).to eq 'Postal Delivery'
      end

      it "Produces readable output for options with more than one element" do
        listing = ListingContent.new(delivery_options: '["Postal Delivery", "In Person Delivery"]')
        expect(ListingContent.display_options(listing.delivery_options)).to eq 'Postal Delivery, In Person Delivery'
      end
    end

    describe "#display_price" do
      it "does not cut decimal points if they exist" do
        listing = ListingContent.new(price: 2.12)
        expect(listing.display_price).to eq "&pound;2.12"
      end

      it "does cut decimal points if they do not exist" do
        listing = ListingContent.new(price: 2.0)
        expect(listing.display_price).to eq "&pound;2.00"
      end

      it "make item free if cost 0" do
        listing = ListingContent.new(price: 0)
        expect(listing.display_price).to eq "Free"
      end
    end

    describe "#listing_url" do
      it "returns the url for the placeholder image if no image is uploaded" do
        listing_images = { images: [] }
        listing = ListingContent.new(listing_images)
        expect(listing.listing_url).to eq "/image-placeholder.png"
      end

      it "returns the url for the image if an image has been uploaded" do
        listing_images = { images: [ActionDispatch::Http::UploadedFile.new({ filename: "test-image-1.jpg", type: "image/jpeg", tempfile: Tempfile.new("listing_spec-test-image-1"), head: "test_headers" })] }
        listing = ListingContent.new(images: listing_images[:images])
        expect(listing.listing_url).to include("test-image-1.jpg")
      end

      it "returns only the first image's url if more than one is uploaded" do
        listing_images = { images: [ActionDispatch::Http::UploadedFile.new({ filename: "test-image-1.jpg", type: "image/jpeg", tempfile: Tempfile.new("listing_spec-test-image-1"), head: "test_headers" }), ActionDispatch::Http::UploadedFile.new({ filename: "test-image-2.png", type: "image/jpeg", tempfile: Tempfile.new("listing_spec-test-image-2"), head: "test_headers2" })] }
        listing = ListingContent.new(images: listing_images[:images])
        expect(listing.listing_url).to include("test-image-1.jpg")
      end
    end

    describe "#images_urls" do
      it "returns an array with only the placeholder image url if no images are uploaded" do
        listing_images = { images: [] }
        listing = ListingContent.new(listing_images)
        expect(listing.image_urls).to eq ["/image-placeholder.png"]
      end

      it "returns an array with a single image url if an image is uploaded" do
        listing_images = { images: [ActionDispatch::Http::UploadedFile.new({ filename: "test-image-1.jpg", type: "image/jpeg", tempfile: Tempfile.new("listing_spec-test-image-1"), head: "test_headers" })] }
        listing = ListingContent.new(images: listing_images[:images])
        expect(listing.image_urls[0]).to include("test-image-1.jpg")
      end

      it "returns an array of all image urls when multiple images are uploaded" do
        listing_images = { images: [ActionDispatch::Http::UploadedFile.new({ filename: "test-image-1.jpg", type: "image/jpeg", tempfile: Tempfile.new("listing_spec-test-image-1"), head: "test_headers" }), ActionDispatch::Http::UploadedFile.new({ filename: "test-image-2.png", type: "image/png", tempfile: Tempfile.new("listing_spec-test-image-2"), head: "test_headers2" })] }
        listing = ListingContent.new(images: listing_images[:images])
        urls = listing.image_urls
        expect(urls.size).to eq 2
        expect(urls[0]).to include("test-image-1.jpg")
        expect(urls[1]).to include("test-image-2.png")
      end
    end

    describe '#print_condition' do
      it 'Returns default when no condition is chosen' do
        listing = ListingContent.new()
        expect(listing.print_condition).to eq 'None specified'
      end

      it 'Returns formatted condition when a condition is chosen' do
        listing = ListingContent.new(condition: "Used")
        expect(listing.print_condition).to eq 'Used'
      end
    end

    describe '#print_delivery_options' do
      it 'Returns default when no delivery options are chosen' do
        listing = ListingContent.new()
        expect(listing.print_delivery_options).to eq 'None specified'
      end

      it 'Returns formatted options when delivery options are chosen' do
        listing = ListingContent.new(delivery_options: '["Postal Delivery", "In Person Delivery"]')
        expect(listing.print_delivery_options).to eq 'Postal Delivery, In Person Delivery'
      end
    end

    describe '#print_payment_options' do
      it 'Returns default when no payment options are chosen' do
        listing = ListingContent.new()
        expect(listing.print_payment_options).to eq 'None specified'
      end

      it 'Returns formatted options when payment options are chosen' do
        listing = ListingContent.new(payment_options: '["Paypal", "Cash"]')
        expect(listing.print_payment_options).to eq 'Paypal, Cash'
      end
    end

    describe '#print_last_modified' do
      it 'Returns a readable output for the date last modified' do
        listing = ListingContent.new(created_at: "2021-04-23 16:55:00")
        expect(listing.print_last_modified).to eq '23/04/2021'
      end
    end

    describe '#delete_contents' do
      it "Modifies the contents of the listing and deletes any older version" do
        listing = FactoryBot.create :listing, user: (FactoryBot.create :user)
        content = FactoryBot.create :listing_content, category: (FactoryBot.create :category), listing: listing
        content = FactoryBot.create :listing_content, category: (FactoryBot.create :category), listing: listing
        content.delete_contents
        new_content = ListingContent.find(content.id)
        expect(new_content.title).to eq '<Removed>'
        expect(new_content.description).to eq '<Removed>'
        expect(new_content.location).to eq '<Removed>'
        expect(ListingContent.where(listing_id: listing.id).count).to eq 1
      end
    end

    describe '#delete_older_versions' do

      it 'Deletes all previous versions of a listing' do
        listing = FactoryBot.create :listing, user: (FactoryBot.create :user)
        category = FactoryBot.create :category
        content1 = FactoryBot.create :listing_content, category: category, listing: listing
        content2 = FactoryBot.create :listing_content, category: category, listing: listing
        content3 = FactoryBot.create :listing_content, category: category, listing: listing
        content3.delete_older_versions
        all_contents = ListingContent.where(listing_id: listing.id)
        expect(all_contents).to_not include content1
        expect(all_contents).to_not include content2
        expect(all_contents).to include content3
      end
    end
    
    describe "#get_payment_options" do
      it "returns \"None\" if there are no payment options" do
        listing_content = ListingContent.new(payment_options: nil)
        expect(listing_content.get_payment_options).to eq "None"
      end

      it "returns the payment options associated with the object" do
        listing_content = ListingContent.new(payment_options: "[\"Cash\", \"Paypal\"]")
        expect(listing_content.get_payment_options).to eq "[\"Cash\", \"Paypal\"]"
      end
    end

    describe "#get_delivery_options" do
      it "returns \"None\" if there are no delivery options" do
        listing_content = ListingContent.new(delivery_options: nil)
        expect(listing_content.get_delivery_options).to eq "None"
      end

      it "returns the delivery options associated with the object" do
        listing_content = ListingContent.new(delivery_options: "[\"Postal Delivery\", \"Collection\"]")
        expect(listing_content.get_delivery_options).to eq "[\"Postal Delivery\", \"Collection\"]"
      end
    end

    describe "#get_condition_options" do
      it "returns \"None\" if there are no condition options" do
        listing_content = ListingContent.new(condition: nil)
        expect(listing_content.get_condition_options).to eq "None"
      end

      it "returns the condition options associated with the object" do
        listing_content = ListingContent.new(condition: "[\"Used\"]")
        expect(listing_content.get_condition_options).to eq "[\"Used\"]"
      end
    end

    describe "#match_filter?" do
      it "returns true if no arguments are passed" do
        listing_content = ListingContent.new
        expect(listing_content.match_filter?).to be true
      end

      it "returns true if all the arguments match the object's attributes" do
        category = Category.new(id: 1, name: "category")
        listing_content = ListingContent.new(title: "title",
                                             delivery_options: "[\"Postal Delivery\", \"Collection\"]",
                                             payment_options: "[\"Cash\", \"Paypal\"]",
                                             condition: "[\"Used\"]",
                                             price: 10,
                                             category_id: category.id)

        is_match = listing_content.match_filter?(title = "title",
                                                 category = category.id.to_s,
                                                 payment_options = ["Cash", "Paypal"],
                                                 delivery_options = ["Postal Delivery", "Collection"],
                                                 condition = ["Used"],
                                                 price_ub = 10.to_s,
                                                 price_lb = 10.to_s)

        expect(is_match).to be true
      end

      it "returns false if any of the arguments do not match the object's attributes" do
        category = Category.new(id: 1, name: "category")
        listing_content = ListingContent.new(title: "title",
                                             delivery_options: "[\"Postal Delivery\", \"Collection\"]",
                                             payment_options: "[\"Cash\", \"Paypal\"]",
                                             condition: "[\"Used\"]",
                                             price: 10,
                                             category_id: category.id)

        is_match = listing_content.match_filter?(title = "title",
                                                 category = (category.id + 1).to_s,
                                                 payment_options = ["Cash", "Paypal"],
                                                 delivery_options = ["Postal Delivery", "Collection"],
                                                 condition = ["Used"],
                                                 price_ub = 10.to_s,
                                                 price_lb = 10.to_s)

        expect(is_match).to be false
      end
    end

    describe "#title_contains_string?" do
      it "returns true if the string argument is nil" do
        expect(ListingContent.new.title_contains_string?(nil)).to be true
      end

      it "returns true if the string is contained in the title of the object" do
        expect(ListingContent.new(title: "test_title").title_contains_string?("test")).to be true
      end

      it "returns false if the string is not contained within the title of the object" do
        expect(ListingContent.new(title: "test_title").title_contains_string?("le_title")).to be false
      end
    end

    describe "#is_category?" do
      it "returns true if the category argument is nil" do
        expect(ListingContent.new.is_category?(nil)).to be true
      end

      it "returns true if the category argument matches the object's category" do
        category = Category.new(id: 1, name: "category")
        expect(ListingContent.new(category_id: category.id).is_category?(category.id.to_s)).to be true
      end

      it "returns false if the category argument does no match the object's category" do
        category = Category.new(id: 1, name: "category")
        expect(ListingContent.new(category_id: category.id).is_category?((category.id + 1).to_s)).to be false
      end
    end

    describe "#price_in_range?" do
      it "returns true if neither the upper or lower bound is set" do
        expect(ListingContent.new.price_in_range?(nil, nil)).to be true
      end

      it "returns true if the lower bound is set and the object's price is higher or the same" do
        expect(ListingContent.new(price: 4).price_in_range?("3", nil)).to be true
        expect(ListingContent.new(price: 3).price_in_range?("3", nil)).to be true
      end

      it "returns false if the lower bound is set and the object's price is lower" do
        expect(ListingContent.new(price: 2).price_in_range?("3", nil)).to be false
      end

      it "returns true if the upper bound is set and the object's price is higher or the same" do
        expect(ListingContent.new(price: 5).price_in_range?(nil, "5")).to be true
      end

      it "returns false if the upper bound is set and the object's price is lower" do
        expect(ListingContent.new(price: 7).price_in_range?(nil, "5")).to be false
      end

      it "returns true if the upper and lower bound are set and the object's price is between those bounds" do
        expect(ListingContent.new(price: 4).price_in_range?("3", "5")).to be true
      end

      it "returns false if the upper and lower bound are set and the object's price is not between those bounds" do
        expect(ListingContent.new(price: 2).price_in_range?("3", "5")).to be false
        expect(ListingContent.new(price: 100).price_in_range?("3", "5")).to be false
      end
    end

    describe "#has_payment_options?" do
      it "returns true if the options argument is nil" do
        expect(ListingContent.new.has_payment_options?(nil)).to be true
      end

      it "returns false if the options argument is an empty array" do
        expect(ListingContent.new.has_payment_options?([])).to be false
      end

      it "returns false if the options argument is not one of the object's payment options" do
        expect(ListingContent.new(payment_options: "[\"Cash\", \"Paypal\"]").has_payment_options?(["Bank Transfer"])).to be false
      end

      it "returns true if any of the items in the options argument are within the object's payment options" do
        expect(ListingContent.new(payment_options: "[\"Paypal\", \"Bank Transfer\"]").has_payment_options?(["Bank Transfer", "cash"])).to be true
      end
    end

    describe "#has_delivery_options?" do
      it "returns true if the options argument is nil" do
        expect(ListingContent.new.has_delivery_options?(nil)).to be true
      end

      it "returns false if the options argument is an empty array" do
        expect(ListingContent.new(delivery_options: "[]").has_delivery_options?([])).to be false
      end

      it "returns false if the options argument is not one of the object's delivery options" do
        expect(ListingContent.new(delivery_options: "[\"Postal Delivery\", \"Collection\"]").has_delivery_options?(["In Person Delivery"])).to be false
      end

      it "returns true if any of the items in the options argument are within the object's delivery options" do
        expect(ListingContent.new(delivery_options: "[\"Collection\", \"In Person Delivery\"]").has_delivery_options?(["In Person Delivery", "Postal Delivery"])).to be true
      end
    end

    describe "#has_condition_options?" do
      it "returns true if the options argument is nil" do
        expect(ListingContent.new.has_condition_options?(nil)).to be true
      end

      it "returns false if the options argument is an empty array" do
        expect(ListingContent.new(condition: "[\"Used\"]").has_condition_options?([])).to be false
      end

      it "returns false if the options argument is not one of the object's condition options" do
        expect(ListingContent.new(condition: "[\"Used\"]").has_condition_options?(["Well Used"])).to be false
      end

      it "returns true if any of the items in the options argument are within the object's condition options" do
        expect(ListingContent.new(condition: "[\"Used\"]").has_condition_options?(["Used", "Well Used"])).to be true
      end
    end
  end
end
