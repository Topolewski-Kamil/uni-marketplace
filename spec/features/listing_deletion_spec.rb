require 'rails_helper'

describe 'Listing Deletion' do

  before do
    @moderator = FactoryBot.create :user, givenname: 'Moderator', sn: 'ModeratorSn', moderator: true
    @userSeller = FactoryBot.create :user, givenname: 'SellerName', sn: 'SellerSurname', moderator: false
    @userSeller2 = FactoryBot.create :user, givenname: 'Seller2Name', sn: 'Seller2Surname', moderator: false
    category = FactoryBot.create :category

    @listing = FactoryBot.create :listing, user: @userSeller
    FactoryBot.create :listing_content, title: 'First Title', price: '1.5', description: 'MyDescription', category: category, delivery_options: 'Postal Delivery, Collection', payment_options: 'Cash, Bank Transfer', approved: true, listing_id: @listing.id
    @listing2 = FactoryBot.create :listing, user: @userSeller2
    FactoryBot.create :listing_content, title: 'Second Title', price: '1.5', description: 'MyDescription', category: category, delivery_options: 'Postal Delivery, Collection', payment_options: 'Cash, Bank Transfer', approved: true, listing_id: @listing2.id
    
    @conversation = FactoryBot.create :conversation, listing: @listing2, seller: @userSeller2, buyer: @moderator

    @listing3 = FactoryBot.create :listing, user: @userSeller2
    FactoryBot.create :listing_content, title: 'Third Title', price: '1.5', description: 'MyDescription', category: category, delivery_options: 'Postal Delivery, Collection', payment_options: 'Cash, Bank Transfer', approved: true, listing_id: @listing3.id
    @conversation2 = FactoryBot.create :conversation, listing: @listing3, seller: @userSeller, buyer: @moderator
    @message = FactoryBot.create :message, conversation: @conversation2, user: @moderator

  end

  context 'As a logged in moderator' do

    before do 
      login_as(@moderator, scope: :user)
    end

    specify "I can delete a listing that isn't my own without deleting the corresponding conversation" do
      visit '/listings/' + @listing3.id.to_s
      click_link 'view-listing-delete-button'
      expect(current_path).to eq '/'
      expect(page).to have_content 'Listing was deleted'
      expect(page).to have_content 'First Title'
      expect(page).to have_content 'Second Title'
      expect(page).to_not have_content 'Third Title'
      visit '/conversations/' + @conversation2.id.to_s
      expect(page).to have_content 'SellerName'
      expect(page).to have_content '<Removed>'
      click_link '<Removed>'
      expect(page).to have_content 'SellerName'
      expect(page).to have_content 'Moderator'
      expect(page).to have_content 'MyText'
    end

    specify "Deleting a listing doesn't add it to the moderation queue" do
      visit '/listings/' + @listing.id.to_s
      click_link 'view-listing-delete-button'
      visit '/listing_review'
      expect(page).to_not have_content 'First Title'
    end
  end

  context 'As a logged in user' do

    before do 
      login_as(@userSeller2, scope: :user)
    end

    # Removed delete button from profile page
    #specify 'I can delete my own listing from my profile' do
    #  visit '/users/' + @userSeller2.id.to_s
    #  expect(page).to have_content 'Second Title'
    #  expect(page).to have_button 'Delete'
    #  click_button "delete_listing#{@listing2.id}"
    #  expect(current_path).to eq '/'
    #  expect(page).to have_content 'Listing was deleted'
    #  expect(page).to_not have_content 'Second Title'
    #end

    specify "I cannot delete a listing that isn't my own" do
      visit '/users/' + @userSeller.id.to_s
      expect(page).to have_content 'First Title'
      expect(page).to_not have_content 'Delete'
    end

    specify "I cannot view a deleted listing anymore" do
      visit '/listings/' + @listing2.id.to_s
      click_link 'view-listing-delete-button'
      visit '/listings/' + @listing2.id.to_s
      expect(current_path).to eq '/'
      expect(page).to have_content 'This listing is not available for viewing'
    end
  end
end