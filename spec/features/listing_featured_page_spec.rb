require 'rails_helper'

describe 'Featured Listings Page' do

  before do
    @user = FactoryBot.create(:user, sn: "BuyerSurname", givenname: "BuyerName")
    login_as(@user, scope: :user)
    @category = FactoryBot.create :category, name: 'Book'
  end

  specify "If no listings, message shown in each section" do
    visit '/'
    expect(page).to have_content 'Newest Items'
    expect(page).to have_content 'Free Items'
    expect(page).to have_content 'Swappable Items'
    within(:css, '.new-listings') { expect(page).to have_content 'There are none of these listings available'}
    within(:css, '.free-listings') { expect(page).to have_content 'There are none of these listings available'}
    within(:css, '.swap-listings') { expect(page).to have_content 'There are none of these listings available'}
  end

  context "A listing has been created" do
    
    before do
      @listing = FactoryBot.create :listing_content, title: "Test Listing", price: 25.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id
    end

    specify 'I can view details of the listing on the featured page' do
      visit '/'
      expect(page).to have_content 'Test Listing'
      expect(page).to have_content 'Book'
      expect(page).to have_content '£25'
    end

    specify 'The first image is displayed on the featured page' do
      @listing.images.attach(ActionDispatch::Http::UploadedFile.new({filename: "test-image-1.jpg", type: "image/jpeg", tempfile: Tempfile.new('edit_listing_spec-test-image-1'), head: 'test_headers'}))
      @listing.images.attach(ActionDispatch::Http::UploadedFile.new({filename: "test-image-2.png", type: "image/png", tempfile: Tempfile.new('edit_listing_spec-test-image-2'), head: 'test_headers2'}))
      visit '/'
      expect(page).to have_xpath("//img[contains(@src,'test-image-1.jpg')]")
      expect(page).to_not have_xpath("//img[contains(@src,'test-image-2.png')]")
    end

    specify 'A placeholder image is displayed if no images are uploaded' do
      visit '/'
      expect(page).to have_xpath("//img[contains(@src,'image-placeholder.png')]")
    end

    context "The listing has been edited" do

      before do
        @edit = FactoryBot.create :listing_content, title: "Test Listing2", price: 0, category_id: @category.id, listing_id: @listing.listing_id
      end

      specify 'Only the most recent approved edit is shown if edit is not approved' do
        visit '/'
        expect(page).to have_content 'Test Listing'
        expect(page).to have_content 'Book'
        expect(page).to have_content '£25'
      end

      specify 'Most recent edit shown if edit has been approved' do
        @edit.update(approved: true)
        visit '/'
        expect(page).to have_content 'Test Listing2'
        expect(page).to have_content 'Free'
      end
    end
  end

  context "There are multiple listings" do

    before do
      @example = FactoryBot.create :listing_content, title: "Listing1", price: 1.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id, payment_options: '["Swap"]'
      FactoryBot.create :listing_content, title: "Listing2", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id, payment_options: '["Swap"]'
      FactoryBot.create :listing_content, title: "Listing3", price: 0.00, category_id: @category.id, listing_id: (FactoryBot.create :listing, user: @user).id, payment_options: '["Swap"]'
      FactoryBot.create :listing_content, title: "Listing4", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id, payment_options: '["Swap"]'
    end

    specify 'Only approved listings are shown' do
      visit '/'
      expect(page).to have_content 'Listing1'
      expect(page).to have_content 'Listing2'
      expect(page).to_not have_content 'Listing3'
      expect(page).to have_content 'Listing4'
    end

    specify 'No listing on new shelf is on swap or free shelves' do
      visit '/'
      within(:css, '.new-listings') do 
        expect(page).to have_content 'Listing1'
        expect(page).to have_content 'Listing2'
        expect(page).to have_content 'Listing4'
      end
      within(:css, '.free-listings') do 
        expect(page).to_not have_content 'Listing1'
        expect(page).to_not have_content 'Listing2'
        expect(page).to_not have_content 'Listing3'
        expect(page).to_not have_content 'Listing4'
      end
      within(:css, '.swap-listings') do 
        expect(page).to_not have_content 'Listing1'
        expect(page).to_not have_content 'Listing2'
        expect(page).to_not have_content 'Listing3'
        expect(page).to_not have_content 'Listing4'
      end
    end

    specify 'Listings with more than one version are shown in the shelf.' do
      FactoryBot.create :listing_content, title: "Listing1.2", price: 10.00, category_id: @category.id, listing_id: @example.listing_id, approved: true
      visit '/'
      within(:css, '.new-listings') do
        expect(page).to have_content 'Listing1'
        expect(page).to have_content 'Listing2'
        expect(page).to have_content 'Listing4'
      end
    end

    context "There are more than 6 new listings" do

      before do
        FactoryBot.create :listing_content, title: "Listing5", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id, payment_options: '["Swap","Cash"]'
        FactoryBot.create :listing_content, title: "Listing6", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id, payment_options: '["Swap"]'
        FactoryBot.create :listing_content, title: "Listing7", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id, payment_options: '["Swap"]'
        FactoryBot.create :listing_content, title: "Listing8", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id, payment_options: '["Swap"]'
        FactoryBot.create :listing_content, title: "Listing9", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id, payment_options: '["Swap"]'
        FactoryBot.create :listing_content, title: "Listing10", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id, payment_options: '["Swap"]'
        ListingContent.find_by(title: 'Listing3').update(approved: true)
      end

      specify "Only the first 6 new listings are shown in new shelf" do
        visit '/'
        within(:css, '.new-listings') do 
          expect(page).to have_content 'Listing10'
          expect(page).to have_content 'Listing9'
          expect(page).to have_content 'Listing5'
          expect(page).to have_content 'Listing6'
          expect(page).to have_content 'Listing7'
          expect(page).to have_content 'Listing8'
          expect(page).to_not have_content 'Listing4'
        end
      end

      specify "No free listings on new shelf are included on free shelf" do
        visit '/'
        within(:css, '.free-listings') do 
          expect(page).to have_content 'Listing4'
          expect(page).to_not have_content 'Listing9'
          expect(page).to_not have_content 'Listing10'
        end
      end

      specify "No swappable listings on new shelf are included on swap shelf" do
        visit '/'
        within(:css, '.swap-listings') do
          expect(page).to have_content 'Listing1'
          expect(page).to_not have_content 'Listing10'
          expect(page).to_not have_content 'Listing9'
        end
      end

      context "There are more than 6 free listings" do
        before do 
          FactoryBot.create :listing_content, title: "Listing11", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id
          FactoryBot.create :listing_content, title: "Listing12", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id
          FactoryBot.create :listing_content, title: "Listing13", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id
          FactoryBot.create :listing_content, title: "Listing14", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id, payment_options: '["Swap"]'
          FactoryBot.create :listing_content, title: "Listing15", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id
          FactoryBot.create :listing_content, title: "Listing16", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id, payment_options: '["Swap"]'
          FactoryBot.create :listing_content, title: "Listing17", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id
          FactoryBot.create :listing_content, title: "Listing18", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id, payment_options: '["Swap"]'
          FactoryBot.create :listing_content, title: "Listing19", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id
        end

        specify "Only the first 6 shelfless free listings are shown" do
          visit '/'
          within(:css, '.free-listings') do
            expect(page).to_not have_content 'Listing6'
            expect(page).to_not have_content 'Listing7'
            expect(page).to have_content 'Listing8'
            expect(page).to have_content 'Listing9'
            expect(page).to have_content 'Listing10'
            expect(page).to have_content 'Listing11'
            expect(page).to have_content 'Listing12'
            expect(page).to have_content 'Listing13'
          end
        end

        specify "No swappable listings on free shelf are included on swap shelf" do
          visit '/'
          within(:css, '.swap-listings') do 
            expect(page).to have_content 'Listing5'
            expect(page).to have_content 'Listing6'
            expect(page).to have_content 'Listing7'
            expect(page).to_not have_content 'Listing8'
            expect(page).to_not have_content 'Listing9'
            expect(page).to_not have_content 'Listing10'
            expect(page).to_not have_content 'Listing11'
            expect(page).to_not have_content 'Listing12'
            expect(page).to_not have_content 'Listing13'
          end
        end

        context "There are more than 6 swappable listings" do

          before do
            FactoryBot.create :listing_content, title: "Listing20", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id, payment_options: '["Swap"]'
            FactoryBot.create :listing_content, title: "Listing21", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id, payment_options: '["Swap"]'
            FactoryBot.create :listing_content, title: "Listing22", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id, payment_options: '["Swap"]'
            FactoryBot.create :listing_content, title: "Listing23", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id, payment_options: '["Swap"]'
            FactoryBot.create :listing_content, title: "Listing24", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id, payment_options: '["Swap"]'
            FactoryBot.create :listing_content, title: "Listing25", price: 0.00, category_id: @category.id, approved: true, listing_id: (FactoryBot.create :listing, user: @user).id, payment_options: '["Swap"]'
          end

          specify "Only the first 6 shelfless swappable listings are shown" do
            visit '/'
            within(:css, '.swap-listings') do
              expect(page).to_not have_content 'Listing2'
              expect(page).to_not have_content 'Listing14'
              expect(page).to have_content 'Listing5'
              expect(page).to have_content 'Listing6'
              expect(page).to have_content 'Listing7'
              expect(page).to have_content 'Listing8'
              expect(page).to have_content 'Listing9'
              expect(page).to have_content 'Listing10'
            end
          end
        end
      end
    end
  end
end