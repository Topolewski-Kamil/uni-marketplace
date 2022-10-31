require "rails_helper"

describe "Creating Conversations" do

  before do
    @userBuyer = FactoryBot.create :user, givenname: 'BuyerName', sn: 'BuyerSurname' 
    @userBuyer2 = FactoryBot.create :user, givenname: 'AnotherBuyerName', sn: 'AnotherBuyerSurname' 

    @userSeller = FactoryBot.create :user, givenname: 'SellerName', sn: 'SellerSurname' 
    @userSeller2 = FactoryBot.create :user, givenname: 'AnotherSellerName', sn: 'AnotherSellerSurname' 

    category = FactoryBot.create :category
    @listing = FactoryBot.create :listing_content, category: category, listing_id: (FactoryBot.create :listing, user: @userSeller).id, approved: true
    @listing2 = FactoryBot.create :listing_content, category: category, listing_id: (FactoryBot.create :listing, user: @userSeller2).id, approved: true
    FactoryBot.create :conversation, seller: @userSeller, buyer: @userBuyer, listing_id: @listing.listing_id
  end


  context 'as a user' do
    before do
      login_as(@userBuyer, scope: :user)
    end

    specify 'i can create a conversation' do
      visit '/listings/' + @listing.listing_id.to_s
      click_button 'Contact Seller'
      expect(page).to have_content @userBuyer.givenname
      expect(page).to have_content @userSeller.givenname
      expect(page).to have_content @listing.title
    end

  end

  context 'after clicking on conversations' do

    before do
      login_as(@userBuyer, scope: :user)
    end
    
    specify 'i am on conversation page' do
      visit '/'
      click_link 'Conversations'
      expect(current_path).to eq "/conversations"
    end
  end

  context 'as a buyer on conversations page' do

    before do
      login_as(@userBuyer, scope: :user)
    end

    specify 'i can see my ongoing conversations page' do
      visit '/conversations'
      expect(page).to have_content @listing.title
    end
  end

  context 'as a seller on conversations page' do

    before do
      login_as(@userSeller, scope: :user)
    end

    specify 'i can see my ongoing conversations page' do
      visit '/conversations'
      expect(page).to have_content @listing.title
    end
  end
  
  context 'as a user' do

    before do
      login_as(@userBuyer, scope: :user)
    end

    specify 'does not crash when adding twice conversation to the same listing by the same user' do
      visit '/listings/' + @listing.listing_id.to_s
      click_button 'Contact Seller'
      expect(page).to have_content @userSeller.givenname
      expect(page).to have_content @listing.title
      visit '/listings/' + @listing.listing_id.to_s
      click_button 'Contact Seller'
      expect(page).to have_content @userSeller.givenname
      expect(page).to have_content @listing.title
    end

    specify 'does not crash when adding twice conversation to the same listing by different user' do
      visit '/listings/' + @listing.listing_id.to_s
      click_button 'Contact Seller'
      expect(page).to have_content @userSeller.givenname
      expect(page).to have_content @listing.title
      login_as(@userBuyer2, scope: :user)
      visit '/listings/' + @listing.listing_id.to_s
      click_button 'Contact Seller'
      expect(page).to have_content @userSeller.givenname
      expect(page).to have_content @listing.title
    end

    specify 'can add two different conversation to the diffeent listing by the same user' do
      visit '/listings/' + @listing.listing_id.to_s
      click_button 'Contact Seller'
      expect(page).to have_content @userSeller.givenname
      expect(page).to have_content @listing.title
      visit '/listings/' + @listing2.listing_id.to_s
      click_button 'Contact Seller'
      expect(page).to have_content @userSeller.givenname
      expect(page).to have_content @listing2.title
    end

    specify 'can add two different conversation to the diffeent listing by the same user' do
      visit '/listings/' + @listing.listing_id.to_s
      click_button 'Contact Seller'
      expect(page).to have_content @userSeller.givenname
      expect(page).to have_content @listing.title
      visit '/listings/' + @listing2.listing_id.to_s
      click_button 'Contact Seller'
      expect(page).to have_content @userSeller2.givenname
    end
  end
end