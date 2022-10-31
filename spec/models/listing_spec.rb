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
require "rails_helper"

RSpec.describe User, type: :model do
  describe Listing do

    before do
      @user = FactoryBot.create :user, givenname: "Test", sn: "Name"
      @category = FactoryBot.create :category
    end

    describe '#find_listing' do

      it "Finds correct listing by the listing's id" do
        listing = FactoryBot.create :listing, user: @user
        expect(Listing.find_listing(listing.id)).to eq listing
      end
    end

    describe "#select_pending" do

      it 'Returns an empty list when there are no listings' do
        expect(Listing.select_pending).to eq []
      end

      it 'Returns an empty list when there are no pending listings' do
        FactoryBot.create :listing_content, category: @category, listing_id: (FactoryBot.create :listing, user: @user).id, approved: true
        expect(Listing.select_pending).to eq []
      end

      it 'Returns a list of the listings that are pending and not deleted' do
        listing1 = FactoryBot.create :listing, user: @user
        listing2 = FactoryBot.create :listing, user: @user, deleted: true
        FactoryBot.create :listing_content, category: @category, listing_id: listing1.id
        FactoryBot.create :listing_content, category: @category, listing_id: listing1.id, approved: true
        FactoryBot.create :listing_content, category: @category, listing_id: listing1.id
        FactoryBot.create :listing_content, category: @category, listing_id: listing2.id
        expect(Listing.select_pending).to include listing1
        expect(Listing.select_pending).to_not include listing2
      end
    end

    describe "#select_approved_listings" do
      it "returns all listings with an approved version" do
        approved_ids = [1, 3, 4, 5, 7, 9, 11]
        for i in 1..12
          ListingContent.new(listing_id: Listing.new(id: i).id, approved: (approved_ids.include? i))
        end
        listings = Listing.select_approved_listings
        listings.each do |listing|
          expect(approved_ids).to include(listing.id)
        end
      end

      it "returns an empty list when there are no listings" do
        expect(Listing.select_approved_listings).to eq []
      end

      it "returns an empty list when there are no listings with approved versions" do
        for i in 1..10
          ListingContent.new(listing_id: Listing.new(id: i).id, approved: false)
        end
        expect(Listing.select_approved_listings).to eq []
      end
    end

    describe "#newest" do
      it "returns an empty list when there are no listings" do
        expect(Listing.newest(1)).to eq []
      end

      it "returns 2 listings in order of date created when there are only 2" do
        listing1 = FactoryBot.create(:listing, created_at: "23-04-2021", user: FactoryBot.create(:user))
        listing2 = FactoryBot.create(:listing, created_at: "24-04-2021", user: FactoryBot.create(:user))
        category = FactoryBot.create(:category)
        listing_content1 = FactoryBot.create(:listing_content, approved: true, category: category, listing: listing1)
        listing_content2 = FactoryBot.create(:listing_content, approved: true, category: category, listing: listing2)

      expect(Listing.newest(2)).to eq [listing2, listing1]
      end

      it "returns only the number of listings of the count argument" do
        category = FactoryBot.create(:category)
        for i in 1..20
          FactoryBot.create(:listing_content, approved: true, category: category, listing: FactoryBot.create(:listing, created_at: "#{i}-04-2021", user: FactoryBot.create(:user)))
        end

        for i in 1..20
          expect(Listing.newest(i).count).to eq i
        end
      end
    end

    describe "#newest_free" do
      it "returns an empty list when there are no listings" do
        expect(Listing.newest_free(1,[])).to eq []
      end

      it "returns 2 listings in order of date created when there are only 2 free listings" do
        listing1 = FactoryBot.create(:listing, created_at: "23-04-2021", user: FactoryBot.create(:user))
        listing2 = FactoryBot.create(:listing, created_at: "24-04-2021", user: FactoryBot.create(:user))
        listing3 = FactoryBot.create(:listing, created_at: "25-04-2021", user: FactoryBot.create(:user))
        category = FactoryBot.create(:category)
        listing_content1 = FactoryBot.create(:listing_content, approved: true, price: 0, category: category, listing: listing1)
        listing_content2 = FactoryBot.create(:listing_content, approved: true, price: 0, category: category, listing: listing2)
        listing_content3 = FactoryBot.create(:listing_content, approved: true, category: category, listing: listing3)
      expect(Listing.newest_free(2,[])).to eq [listing2, listing1]
      end

      it "returns only the number of listings of the count argument" do
        category = FactoryBot.create(:category)
        for i in 1..20
          FactoryBot.create(:listing_content, approved: true, price: 0, category: category, listing: FactoryBot.create(:listing, created_at: "#{i}-04-2021", user: FactoryBot.create(:user)))
        end

        for i in 1..20
          expect(Listing.newest_free(i,[]).count).to eq i
        end
      end

      it "only returns the listings that don't appear in another list" do
        listing1 = FactoryBot.create(:listing, created_at: "23-04-2021", user: FactoryBot.create(:user))
        listing2 = FactoryBot.create(:listing, created_at: "24-04-2021", user: FactoryBot.create(:user))
        listing3 = FactoryBot.create(:listing, created_at: "25-04-2021", user: FactoryBot.create(:user))
        category = FactoryBot.create(:category)
        listing_content1 = FactoryBot.create(:listing_content, approved: true, price: 0, category: category, listing: listing1)
        listing_content2 = FactoryBot.create(:listing_content, approved: true, price: 0, category: category, listing: listing2)
        listing_content3 = FactoryBot.create(:listing_content, approved: true, price: 0, category: category, listing: listing3)
        expect(Listing.newest_free(3,[listing2])).to eq [listing3,listing1]
      end
    end

    describe "#newest_exchanges" do
      it "returns an empty list when there are no listings" do
        expect(Listing.newest_exchanges(1,[])).to eq []
      end

      it "returns 2 listings in order of date created when there are only 2 exchangable listings" do
        listing1 = FactoryBot.create(:listing, created_at: "23-04-2021", user: FactoryBot.create(:user))
        listing2 = FactoryBot.create(:listing, created_at: "24-04-2021", user: FactoryBot.create(:user))
        listing3 = FactoryBot.create(:listing, created_at: "25-04-2021", user: FactoryBot.create(:user))
        category = FactoryBot.create(:category)
        listing_content1 = FactoryBot.create(:listing_content, approved: true, payment_options: '["Swap"]', category: category, listing: listing1)
        listing_content2 = FactoryBot.create(:listing_content, approved: true, payment_options: '["Swap"]', category: category, listing: listing2)
        listing_content3 = FactoryBot.create(:listing_content, approved: true, category: category, listing: listing3)
        expect(Listing.newest_exchanges(2,[])).to eq [listing2, listing1]
      end

      it "returns only the number of listings of the count argument" do
        category = FactoryBot.create(:category)
        for i in 1..20
          FactoryBot.create(:listing_content, approved: true, payment_options: '["Swap"]', category: category, listing: FactoryBot.create(:listing, created_at: "#{i}-04-2021", user: FactoryBot.create(:user)))
        end

        for i in 1..20
          expect(Listing.newest_exchanges(i,[]).count).to eq i
        end
      end

      it "only returns the listings that don't appear in another list" do
        listing1 = FactoryBot.create(:listing, created_at: "23-04-2021", user: FactoryBot.create(:user))
        listing2 = FactoryBot.create(:listing, created_at: "24-04-2021", user: FactoryBot.create(:user))
        listing3 = FactoryBot.create(:listing, created_at: "25-04-2021", user: FactoryBot.create(:user))
        category = FactoryBot.create(:category)
        listing_content1 = FactoryBot.create(:listing_content, approved: true, payment_options: '["Swap"]', category: category, listing: listing1)
        listing_content2 = FactoryBot.create(:listing_content, approved: true, payment_options: '["Swap"]', category: category, listing: listing2)
        listing_content3 = FactoryBot.create(:listing_content, approved: true, payment_options: '["Swap"]', category: category, listing: listing3)
        expect(Listing.newest_exchanges(3,[listing2])).to eq [listing3,listing1]
      end
    end

    describe "#search" do
      before do
        @nil_params = {
          title: nil,
          category: nil,
          payment_options: nil,
          delivery_option: nil,
          condition: nil,
          lower_bound_price: nil,
          upper_bound_price: nil,
        }
        @sample_params = {
          title: "listing",
          category: "1",
          payment_options: ["Paypal"],
          delivery_options: ["In Person Delivery"],
          condition: ["Used"],
          lower_bound_price: "4",
          upper_bound_price: "6",
        }
      end

      it "returns an empty list when there are no listings" do
        expect(Listing.search(true, @nil_params)).to eq []
      end

      it "returns an empty list when there are no approved listings and the approved argument is true" do
        listing1 = FactoryBot.create(:listing, user: FactoryBot.create(:user))
        listing2 = FactoryBot.create(:listing, user: FactoryBot.create(:user))
        category = FactoryBot.create(:category)
        FactoryBot.create(:listing_content, listing: listing1, approved: false, category: category)

        expect(Listing.search(true, @nil_params)).to eq []
      end

      it "returns all listings, approved and unapproved, when the approved argument is false" do
        listing1 = FactoryBot.create(:listing, user: FactoryBot.create(:user))
        listing2 = FactoryBot.create(:listing, user: FactoryBot.create(:user))
        listing3 = FactoryBot.create(:listing, user: FactoryBot.create(:user))
        category = FactoryBot.create(:category)
        FactoryBot.create(:listing_content, listing: listing1, approved: true, category: category)
        FactoryBot.create(:listing_content, listing: listing2, approved: false, category: category)

        expect(Listing.search(false, @nil_params)).to eq [listing1, listing2]
      end

      it "returns a listing when all the search conditions match the listing's content" do
        listing1 = FactoryBot.create(:listing, user: FactoryBot.create(:user))
        category = FactoryBot.create(:category, id: 1)
        FactoryBot.create(:listing_content,
                          listing: listing1,
                          approved: true,
                          category: category,
                          title: "listing",
                          payment_options: ["Paypal"],
                          delivery_options: ["In Person Delivery"],
                          condition: ["Used"],
                          price: 5)

        expect(Listing.search(false, @sample_params)).to eq [listing1]
      end

      it "returns an empty list when the search conditions don't match any of the listing's content" do
        listing1 = FactoryBot.create(:listing, user: FactoryBot.create(:user))
        category = FactoryBot.create(:category, id: 2)
        FactoryBot.create(:listing_content,
                          listing: listing1,
                          approved: true,
                          category: category,
                          title: "not a listing",
                          payment_options: ["Cash"],
                          delivery_options: ["Postal Delivery"],
                          condition: ["Well Used"],
                          price: 10)

        expect(Listing.search(false, @sample_params)).to eq []
      end
    end

    describe "select_listings_by_category_id" do

      it 'Returns an empty list if there are no listings' do
        expect(Listing.select_listings_by_category_id(0)).to eq []
      end

      it 'Returns an empty list if there are no listings of the category' do
        FactoryBot.create :listing_content, category: (FactoryBot.create :category), listing: (FactoryBot.create :listing, user: (FactoryBot.create :user))
        expect(Listing.select_listings_by_category_id(0)).to eq []
      end

      it 'Returns all listings that belong to a category' do
        listing1 = FactoryBot.create(:listing, created_at: "23-04-2021", user: FactoryBot.create(:user))
        listing2 = FactoryBot.create(:listing, created_at: "24-04-2021", user: FactoryBot.create(:user))
        listing3 = FactoryBot.create(:listing, created_at: "25-04-2021", user: FactoryBot.create(:user))
        category = FactoryBot.create(:category, name: "Wanted")
        listing_content1 = FactoryBot.create(:listing_content, category: (FactoryBot.create :category, name: "Not wanted"), listing: listing1)
        listing_content2 = FactoryBot.create(:listing_content, category: category, listing: listing2)
        listing_content3 = FactoryBot.create(:listing_content, category: category, listing: listing3)
        expect(Listing.select_listings_by_category_id(category.id)).to eq [listing2,listing3]
      end
    end

    describe "#fully_approved?" do
      it "returns false when the listing has no content" do
        listing = FactoryBot.create(:listing, user: FactoryBot.create(:user))
        expect(listing.fully_approved?).to eq false
      end

      it "returns false when the latest content isn't approved" do
        listing = FactoryBot.create(:listing, user: FactoryBot.create(:user))
        category = FactoryBot.create(:category)
        FactoryBot.create(:listing_content, listing: listing, approved: true, category: category)
        FactoryBot.create(:listing_content, listing: listing, approved: false, category: category)
        expect(listing.fully_approved?).to eq false
      end

      it "returns true when the latest content is approved" do
        listing = FactoryBot.create(:listing, user: FactoryBot.create(:user))
        category = FactoryBot.create(:category)
        FactoryBot.create(:listing_content, listing: listing, approved: false, category: category)
        FactoryBot.create(:listing_content, listing: listing, approved: true, category: category)
        expect(listing.fully_approved?).to eq true
      end
    end

    describe "#has_approved_version?" do
      it "returns false when the listing has no content" do
        listing = FactoryBot.create(:listing, user: FactoryBot.create(:user))
        expect(listing.has_approved_version?).to eq false
      end

      it "returns false when there are no approved contents" do
        listing = FactoryBot.create(:listing, user: FactoryBot.create(:user))
        category = FactoryBot.create(:category)
        FactoryBot.create(:listing_content, listing: listing, approved: false, category: category)
        FactoryBot.create(:listing_content, listing: listing, approved: false, category: category)
        expect(listing.has_approved_version?).to eq false
      end

      it "returns true when there is a single approved content" do
        listing = FactoryBot.create(:listing, user: FactoryBot.create(:user))
        category = FactoryBot.create(:category)
        FactoryBot.create(:listing_content, listing: listing, approved: true, category: category)
        FactoryBot.create(:listing_content, listing: listing, approved: false, category: category)
        expect(listing.has_approved_version?).to eq true
      end
    end

    describe "#listing_content" do
      context "approved argument is not set" do
        it "returns nil when there is no associated content" do
          listing = FactoryBot.create(:listing, user: FactoryBot.create(:user))
          expect(listing.listing_content).to eq nil
        end

        it "returns the latest listing content" do
          listing = FactoryBot.create(:listing, user: FactoryBot.create(:user))
          category = FactoryBot.create(:category)
          listing_content1 = FactoryBot.create(:listing_content, listing: listing, approved: true, category: category, created_at: "24-04-2021")
          listing_content2 = FactoryBot.create(:listing_content, listing: listing, approved: true, category: category, created_at: "23-04-2021")
          expect(listing.listing_content).to eq listing_content1
        end

        it "returns the latest content when it is unapproved" do
          listing = FactoryBot.create(:listing, user: FactoryBot.create(:user))
          category = FactoryBot.create(:category)
          listing_content1 = FactoryBot.create(:listing_content, listing: listing, approved: false, category: category, created_at: "24-04-2021")
          listing_content2 = FactoryBot.create(:listing_content, listing: listing, approved: true, category: category, created_at: "23-04-2021")
          expect(listing.listing_content).to eq listing_content1
        end

        it "returns the latest approved listing content when approved is set to true" do
          listing = FactoryBot.create(:listing, user: FactoryBot.create(:user))
          category = FactoryBot.create(:category)
          listing_content1 = FactoryBot.create(:listing_content, listing: listing, approved: false, category: category, created_at: "24-04-2021")
          listing_content2 = FactoryBot.create(:listing_content, listing: listing, approved: true, category: category, created_at: "23-04-2021")
          listing_content3 = FactoryBot.create(:listing_content, listing: listing, approved: true, category: category, created_at: "22-04-2021")
          expect(listing.listing_content true).to eq listing_content2
        end
      end
    end

    describe "#get_all_listing_contents" do

      it "Returns all contents related to the listing" do
        listing = FactoryBot.create :listing, user: (FactoryBot.create :user)
        category = FactoryBot.create :category
        content1 = FactoryBot.create(:listing_content, listing: listing, category: category)
        content2 = FactoryBot.create(:listing_content, listing: listing, approved: true, category: category)
        expect(listing.get_all_listing_contents).to eq [content1,content2]
      end
    end

    describe "#delete_listing" do

      it "Modifies the listing and leaves a redacted version" do
        listing = FactoryBot.create :listing, user: (FactoryBot.create :user)
        content1 = FactoryBot.create(:listing_content, listing: listing, category: (FactoryBot.create :category))
        FactoryBot.create(:listing_content, listing: listing, category: (FactoryBot.create :category))
        listing.delete_listing
        expect(ListingContent.where(id: content1.id)).to eq []
        expect(listing.deleted).to eq true
        expect(listing.listing_content.title).to eq "<Removed>"
        expect(listing.listing_content.description).to eq "<Removed>"
        expect(listing.listing_content.location).to eq "<Removed>"
      end
    end

    describe "#user_can_read?" do

      before do
        @user = (FactoryBot.create :user)
        @other = (FactoryBot.create :user)
        @listing = FactoryBot.create :listing, user: @user
        FactoryBot.create :listing_content, listing: @listing, category: (FactoryBot.create :category)
      end

      it "Returns false if the listing is deleted" do
        @listing.update(deleted: true)
        expect(@listing.user_can_read?(@user)).to eq false
      end

      it "Returns true if there's an approved version of the listing" do
        FactoryBot.create :listing_content, listing: @listing, category: (FactoryBot.create :category), approved: true
        expect(@listing.user_can_read?(@user)).to eq true
      end

      it "Returns false if there isn't an approved version and it wasn't created by the user" do
        expect(@listing.user_can_read?(@other)).to eq false
      end

      it "Returns true if there isn't an approved version and it was created by the user" do
        expect(@listing.user_can_read?(@user)).to eq true
      end
    end

    describe '#generate_listing_hash' do
      it "Returns a hash of the listing and its contents and if its pending approval" do
        listing = FactoryBot.create :listing, user: (FactoryBot.create :user)
        content = FactoryBot.create :listing_content, category: (FactoryBot.create :category), listing: listing, approved: true
        FactoryBot.create :listing_content, category: (FactoryBot.create :category), listing: listing
        hash = listing.generate_listing_hash
        expect(hash[:listing]).to eq listing
        expect(hash[:content]).to eq content
        expect(hash[:pending]).to eq true
      end
    end

    describe '#user_can_update?' do

      before do
        @user = FactoryBot.create :user
        @listing = FactoryBot.create :listing, user: @user
      end

      it "Returns false if the user cannot update the listing" do
        expect(@listing.user_can_update?(FactoryBot.create :user)).to eq false
      end

      it "Returns true if the user can update the listing" do
        expect(@listing.user_can_update?(@user)).to eq true
      end
    end
  end
end
