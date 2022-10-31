require "rails_helper"

describe "Viewing Profile Page" do

  before do
    @user1 = FactoryBot.create :user, givenname: "Mike", sn: "Kowalski"
    @user2 = FactoryBot.create :user, givenname: "John", sn: "Smith"
    login_as(@user1)
  end

  specify "I can access my own profile page" do
    visit "/users/" + @user1.id.to_s
    expect(page).to have_content "Mike K."
    expect(page).to have_content "Add Listing"
    expect(page).to have_content "Settings"
    expect(page).to have_link 'Conversations'
    expect(page).to_not have_content "Report"
  end

  specify "I cannot view another user's page as my own" do
    visit "/users/" + @user2.id.to_s
    within(:css, 'main') do
      expect(page).to have_content "John S."
      expect(page).to_not have_content "Add Listing"
      expect(page).to_not have_content "Settings" 
      expect(page).to_not have_link 'Conversations'
      expect(page).to have_content "Report"
    end
  end

  specify "I can log out using a link on my profile page" do
    visit "/users/" + @user1.id.to_s
    click_link "Log out"
    expect(current_path).to eq '/users/sign_in'
    expect(page).to have_content "You need to sign in or sign up before continuing."
  end

  specify "I can navigate to the listing creation page." do
    visit "/users/" + @user1.id.to_s
    click_link "Add Listing"
    expect(current_path).to eq "/listings/new"
  end

  specify "I can access my conversations from my profile page" do
    visit '/users/' + @user1.id.to_s
    click_link 'Conversations'
    expect(current_path).to eq '/conversations'
  end

  context 'Listings have been created' do

    before do
      category = FactoryBot.create :category, name: "Test"
      @listing1 = FactoryBot.create :listing_content, title: 'Test example 1', category: category, approved: true, listing: (FactoryBot.create :listing, user: @user1)
      @listing2 = FactoryBot.create :listing_content, title: 'Test example 2', category: category, approved: true, listing: (FactoryBot.create :listing, user: @user1)
      @listing3 = FactoryBot.create :listing_content, title: 'Test example 3', category: category, listing: (FactoryBot.create :listing, user: @user1)
      @listing4 = FactoryBot.create :listing_content, title: 'Test example 4', category: category, approved: true, listing: (FactoryBot.create :listing, user: @user2)
      @listing5 = FactoryBot.create :listing_content, title: 'Test example 5', category: category, listing: (FactoryBot.create :listing, user: @user2)
      @listing1.images.attach(io: File.open("spec/testing-assets/images/test-image-1.jpg"), filename: "test-image-1.jpg")
      @listing4.images.attach(io: File.open("spec/testing-assets/images/test-image-2.png"), filename: "test-image-2.png")
    end

    context "The profile is mine" do 

      before do
        visit '/users/' + @user1.id.to_s
      end

      specify "I can view all my listings, both approved and pending" do
        expect(page).to have_content 'Test example 1'
        expect(page).to have_xpath("//img[contains(@src,'test-image-1.jpg')]")
        expect(page).to have_content 'Test example 2'
        expect(page).to have_xpath("//img[contains(@src,'image-placeholder.png')]")
        expect(page).to have_content 'Test example 3'
      end

      specify "All listings pending approval have a message indicating it" do
        expect(page).to have_content 'Pending approval'
      end

      specify "I can see how many listings there are" do
        expect(page).to have_content "You have 3 items listed for sale"
      end

      # Removed delete button from profile page
      #specify "I can delete a listing from my page" do
      #  expect(page).to have_button 'Delete'
      #end
    end

    context "The profile isn't mine" do 

      before do
        visit '/users/' + @user2.id.to_s
      end

      specify "I can view all the listings, but not pending ones" do
        expect(page).to have_content 'Test example 4'
        expect(page).to_not have_content 'Test example 5'
        expect(page).to have_xpath("//img[contains(@src,'test-image-2.png')]")
      end

      specify "I can see how many listings are there" do
        expect(page).to have_content "User has 1 items listed for sale"
      end
    end
  end

  # TODO:
  # - Test Link to settings when added.
end
