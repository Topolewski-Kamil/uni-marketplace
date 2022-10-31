require "rails_helper"

describe "Creating Messages" do

  before do
    @userBuyer = FactoryBot.create :user, givenname: 'BuyerName', sn: 'BuyerSurname' 
    @userSeller = FactoryBot.create :user, givenname: 'SellerName', sn: 'SellerSurname' 
    category = FactoryBot.create :category
    @listing = FactoryBot.create :listing_content, category: category, listing_id: (FactoryBot.create :listing, user: @userSeller).id, approved: true
    @conversation = FactoryBot.create :conversation, seller: @userSeller, buyer: @userBuyer, listing_id: @listing.listing_id
  end

  context 'after clicking on specific conversations' do

    before do
        login_as(@userSeller, scope: :user)
    end
    
    specify 'i am on conversation show page' do
      visit '/conversations/'
      click_link @listing.title
      expect(current_path).to eq '/conversations/' + @conversation.id.to_s
    end
  end

  context 'as user' do
    before do
      login_as(@userSeller, scope: :user)
    end

    # This test needs to be re-done once the 'link' button is implemented
    # specify 'i can go to listing page' do
    #   visit '/conversations/' + @conversation.id.to_s
    #   expect(page).to have_content @listing.title
    #   within('#chat-container') do
    #     click_link @listing.title
    #   end
    #   expect(current_path).to eq '/listings/' + @listing.listing_id.to_s
    # end
  end

  context 'as buyer' do
    before do
      login_as(@userBuyer, scope: :user)
    end

    specify 'i can view and go to seller page' do
      visit '/conversations/' + @conversation.id.to_s
      expect(page).to have_content @userSeller.givenname
      within('#chat-container') do
        click_link @userSeller.givenname
      end
      expect(current_path).to eq '/users/' + @userSeller.id.to_s
    end

    specify 'i can add and view my message' do
      visit '/conversations/' + @conversation.id.to_s
      fill_in 'Say something...', with: 'Sample Message'
      click_button 'conversations-send-button'
      visit '/conversations/' + @conversation.id.to_s
      within('div#chat-box') do
        expect(page).to have_content 'Sample Message'
      end
    end

    specify 'seller can see my message' do
      visit '/conversations/' + @conversation.id.to_s
      fill_in 'Say something...', with: 'Sample Message'
      click_button 'conversations-send-button'
      visit '/conversations/' + @conversation.id.to_s
      within('div#chat-box') do
        expect(page).to have_content 'Sample Message'
      end
      click_link 'Log out'
      login_as(@userSeller, scope: :user)
      visit '/conversations/' + @conversation.id.to_s
      within('div#chat-box') do
        expect(page).to have_content 'Sample Message'
      end
    end
  end

  context 'as seller' do
    before do
      login_as(@userSeller, scope: :user)
    end

    specify 'i can view and go to buyer page' do
      visit '/conversations/' + @conversation.id.to_s
      expect(page).to have_content @userBuyer.givenname
      click_link @userBuyer.givenname
      expect(current_path).to eq '/users/' + @userBuyer.id.to_s
    end

    specify 'i can add and view my message' do
      visit '/conversations/' + @conversation.id.to_s
      fill_in 'Say something...', with: 'Sample Message'
      click_button 'conversations-send-button'
      visit '/conversations/' + @conversation.id.to_s
      within('div#chat-box') do
        expect(page).to have_content 'Sample Message'
      end
    end

    specify 'buyer can see my message' do
      visit '/conversations/' + @conversation.id.to_s
      fill_in 'Say something...', with: 'Sample Message'
      click_button 'conversations-send-button'
      visit '/conversations/' + @conversation.id.to_s
      within('div#chat-box') do
        expect(page).to have_content 'Sample Message'
      end

      click_link 'Log out'
      login_as(@userBuyer, scope: :user)
      visit '/conversations/' + @conversation.id.to_s
      within('div#chat-box') do
        expect(page).to have_content 'Sample Message'
      end
    end

  end
end

