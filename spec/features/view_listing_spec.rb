require 'rails_helper'

describe 'View listing' do

  before do
    userBuyer = FactoryBot.create :user, givenname: 'BuyerName', sn: 'BuyerSurname' 
    @userSeller = FactoryBot.create :user, givenname: 'SellerName', sn: 'SellerSurname' 
    login_as(userBuyer, scope: :user)
    @category = FactoryBot.create :category, name: 'MyCategory'
    @listing = FactoryBot.create :listing_content, title: 'MyTitle', description: 'MyDescription', category: @category, delivery_options: '[Postal Delivery, Collection]', payment_options: '[Cash, Bank Transfer]', listing_id: (FactoryBot.create :listing, user: @userSeller).id, approved: true
    @listing.images.attach(io: File.open("spec/testing-assets/images/test-image-1.jpg"), filename: "test-image-1.jpg")
    @listing.images.attach(io: File.open("spec/testing-assets/images/test-image-2-small.png"), filename: "test-image-2-small.png")

  end

  context 'As a logged in buyer' do

    specify "I can see the seller's name" do
      visit '/listings/' + @listing.listing_id.to_s
      expect(page).to have_content 'SellerName S.'
     end

    specify 'I can see all the listing details' do
      visit '/listings/' + @listing.listing_id.to_s
      expect(page).to have_content 'MyTitle'
      expect(page).to have_content 'MyDescription'
      expect(page).to have_content 'Cash, Bank Transfer'
      expect(page).to have_content 'Postal Delivery, Collection'
      expect(page).to have_content '£12.20'
      expect(page).to have_content 'None specified'
      expect(page).to have_button 'Contact Seller'
      expect(page).to have_link 'Report this item'
    end

    specify "I can see the listing's photos" do
      visit '/listings/' + @listing.listing_id.to_s
      expect(page).to have_xpath("//img[contains(@src,'test-image-1.jpg')]")
      expect(page).to have_xpath("//img[contains(@src,'test-image-2-small.png')]")
    end

    specify "I can go to the seller's profile page" do
      visit '/listings/' + @listing.listing_id.to_s
      click_link "SellerName S."
      expect(current_path).to eq "/users/" + @userSeller.id.to_s
    end

    context "The listing has been edited" do
      before do
        @listing_edit = FactoryBot.create :listing_content, title: 'EditedTitle', description: 'MyDescription', category: @category, delivery_options: '["Postal Delivery", "Collection"]', payment_options: '["Cash", "Bank Transfer"]', listing_id: @listing.listing_id
      end

      specify "I can see if an edit is awaiting moderation" do
        visit "/listings/#{@listing.listing_id}"
        expect(page).to have_content 'MyTitle'
        expect(page).to have_content 'MyDescription'
        expect(page).to have_content 'Cash, Bank Transfer'
        expect(page).to have_content 'Postal Delivery, Collection'
        expect(page).to have_content '£12.20'
        expect(page).to have_content 'None specified'
        expect(page).to have_content 'This listing is awaiting moderation'
      end

      specify "I can see when the listing was last modified once the edit is approved" do
        @listing_edit.update(approved: true)
        visit "/listings/#{@listing.listing_id}"
        expect(page).to_not have_content 'This listing is awaiting moderation'
        expect(page).to have_content 'EditedTitle'
        expect(page).to have_content "#{@listing_edit.created_at.strftime("%d/%m/%Y")}"
      end
    end

    # TODO test for going to report page
    # TODO test for contacting user

  end

end
