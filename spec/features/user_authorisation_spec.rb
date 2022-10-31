require "rails_helper"

describe "User Authorisation" do

  before do
    @user = FactoryBot.create :user, givenname: 'Normal', sn: 'User'
    @mod_user = FactoryBot.create :user, givenname: 'Moderator', sn: 'User', moderator: true
    @listing = FactoryBot.create :listing_content, title: 'Test title', description: 'Test description', price: 1.25, location: 'Test location', delivery_options: '["Collection"]', payment_options: "", condition: "", category: (FactoryBot.create :category, name: 'Test category'), listing_id: (FactoryBot.create :listing, user: @user).id
  end

  context "As a non-logged in user" do

    specify "I can't add a new listing" do
      visit '/listings/new'
      expect(current_path).to eq '/users/sign_in'
    end

    specify "I can't view the featured page" do
      visit '/listings'
      expect(current_path).to eq '/users/sign_in'
    end

    specify "I can't view a specific listing" do
      visit "/listings/#{@listing.listing_id}"
      expect(current_path).to eq '/users/sign_in'
    end

    specify "I can't edit a listing" do
      visit "/listings/#{@listing.listing_id}/edit"
      expect(current_path).to eq '/users/sign_in'
    end

    specify "I can't view a profile" do
      visit "/users/#{@user.id}"
      expect(current_path).to eq '/users/sign_in'
    end

    specify "I can't access the moderator dashboard" do
      visit '/moderator'
      expect(current_path).to eq '/users/sign_in'
    end

    specify "I can't view the moderation queue" do
      visit '/listing_review'
      expect(current_path).to eq '/users/sign_in'
    end
  end

  context "As a logged in normal user" do
    before do
      login_as(@user, scope: :user)
    end

    specify "I can't see the moderator dashboard" do
      visit '/'
      expect(page).to_not have_content 'Moderator Dashboard'
    end

    specify "I can't access the moderator dashboard by URL" do
      visit '/moderator'
      expect(current_path).to eq '/'
      expect(page).to have_content "You are not authorized"
    end

    specify "I can't access the moderation queue by URL" do
      visit '/listing_review'
      expect(current_path).to eq '/'
      expect(page).to have_content "You are not authorized"
    end

    context "A listing has been created" do

      context "The listing was created by me" do

        before do
          @listing = FactoryBot.create :listing_content, title: 'Example title', description: 'Example Description', price: 10.0, category: (FactoryBot.create :category, name: 'Example'), location: 'Example Location', condition: 'Used', delivery_options: '["Collection","Postal Delivery"]', payment_options: '["Cash","Bank Transfer"]', listing_id: (FactoryBot.create :listing, user: @user).id
        end

        specify "I can see all appropriate links on the show page when it's approved" do
          @listing.update(approved: true)
          visit "/listings/#{@listing.listing_id}"
          expect(page).to have_link "Edit"
          expect(page).to_not have_button 'Contact Seller'
          expect(page).to_not have_link 'Report this item'
        end

        specify "I can see the details of a newly added listing that isn't approved" do
          visit "/listings/#{@listing.listing_id}"
          expect(current_path).to eq "/listings/#{@listing.listing_id}"
          expect(page).to have_content 'Example title'
          expect(page).to have_content 'Example Description'
          expect(page).to have_content 'Example Location'
          expect(page).to have_content '£10'
          expect(page).to have_content 'Example'
          expect(page).to have_content 'Collection,Postal Delivery'
          expect(page).to have_content 'Cash,Bank Transfer'
          expect(page).to have_content 'Used'
          expect(page).to have_xpath "//img[contains(@src,'image-placeholder.png')]"
          expect(page).to_not have_button 'Contact Seller'
          expect(page).to_not have_link 'Report this item'
          expect(page).to have_content 'This listing is awaiting moderation'
        end

        specify "I can edit the non-approved listing from the viewing page" do
          visit "/listings/#{@listing.listing_id}"
          expect(page).to have_link 'Edit'
        end

        specify "I can edit the non-approved listing from URL" do
          visit "/listings/#{@listing.listing_id}/edit"
          expect(current_path).to eq "/listings/#{@listing.listing_id}/edit"
          expect(page).to_not have_content 'This listing is awaiting moderation'
        end

        specify "I can only see the most recent edit for a non-approved listing" do
          FactoryBot.create :listing_content, title: 'New title', description: 'Example Description', price: 10.0, category: (FactoryBot.create :category, name: 'Example2'), location: 'Example Location', condition: 'Used', delivery_options: '["Collection","Postal Delivery"]', payment_options: '["Cash","Bank Transfer"]', listing_id: @listing.listing_id
          FactoryBot.create :listing_content, title: 'New title', description: 'Example Description', price: 10.0, category: (FactoryBot.create :category, name: 'Example2'), location: 'Example Location', condition: 'Used', delivery_options: '["Collection","Postal Delivery"]', payment_options: '["Cash","Bank Transfer"]', listing_id: @listing.listing_id
          FactoryBot.create :listing_content, title: 'Newer title', description: 'Example Description', price: 10.0, category: (FactoryBot.create :category, name: 'Example2'), location: 'Example Location', condition: 'Used', delivery_options: '["Collection","Postal Delivery"]', payment_options: '["Cash","Bank Transfer"]', listing_id: @listing.listing_id
          visit "/listings/#{@listing.listing_id}"
          expect(current_path).to eq "/listings/#{@listing.listing_id}"
          expect(page).to have_content 'Newer title'
          expect(page).to have_link 'Edit'
        end

        specify "I can only see the most recent edit for an approved listing" do
          @listing.update(approved: true)
          FactoryBot.create :listing_content, title: 'New title', description: 'Example Description', price: 10.0, category: (FactoryBot.create :category, name: 'Example2'), location: 'Example Location', condition: 'Used', delivery_options: '["Collection","Postal Delivery"]', payment_options: '["Cash","Bank Transfer"]', listing_id: @listing.listing_id
          visit "/listings/#{@listing.listing_id}"
          expect(current_path).to eq "/listings/#{@listing.listing_id}"
          expect(page).to have_content 'Example title'
          expect(page).to have_content 'Example Description'
          expect(page).to have_content 'Example Location'
          expect(page).to have_content '£10'
          expect(page).to have_content 'Example'
          expect(page).to have_content 'Collection,Postal Delivery'
          expect(page).to have_content 'Cash,Bank Transfer'
          expect(page).to have_content 'Used'
          expect(page).to have_xpath "//img[contains(@src,'image-placeholder.png')]"
          expect(page).to_not have_button 'Contact Seller'
          expect(page).to_not have_link 'Report this item'
          expect(page).to have_link 'Edit'
        end
      end

      context "The listing was created by someone else" do

        before do
          @listing = FactoryBot.create :listing_content, title: 'Example title', description: 'Example Description', price: 10.0, category: (FactoryBot.create :category, name: 'Example'), location: 'Example Location', condition: 'Used', delivery_options: '["Collection","Postal Delivery"]', payment_options: '["Cash","Bank Transfer"]', listing_id: (FactoryBot.create :listing, user: @mod_user).id
        end

        specify "I cannot see the listing if it's not approved" do
          visit "/listings/#{@listing.listing_id}"
          expect(current_path).to eq '/'
          expect(page).to have_content "This listing is not available for viewing"
        end

        specify "I can only view the details of the approved listing" do
          @listing.update(approved: true)
          visit "/listings/#{@listing.listing_id}"
          expect(current_path).to eq "/listings/#{@listing.listing_id}"
          expect(page).to have_content 'Example title'
          expect(page).to have_content 'Example Description'
          expect(page).to have_content 'Example Location'
          expect(page).to have_content '£10'
          expect(page).to have_content 'Example'
          expect(page).to have_content 'Collection,Postal Delivery'
          expect(page).to have_content 'Cash,Bank Transfer'
          expect(page).to have_content 'Used'
          expect(page).to have_xpath "//img[contains(@src,'image-placeholder.png')]"
          expect(page).to have_button 'Contact Seller'
          expect(page).to have_link 'Report this item'
          expect(page).to_not have_link 'Edit'
        end

        specify "I cannot edit the listing from URL" do
          visit "/listings/#{@listing.listing_id}/edit"
          expect(current_path).to eq '/'
          expect(page).to have_content "You can't edit this listing"
        end

        specify "I can only see the most recent edit" do
          @listing.update(approved: true)
          FactoryBot.create :listing_content, title: 'New title', description: 'Example Description', price: 10.0, category: (FactoryBot.create :category, name: 'Example2'), location: 'Example Location', condition: 'Used', delivery_options: '["Collection","Postal Delivery"]', payment_options: '["Cash","Bank Transfer"]', listing_id: @listing.listing_id
          visit "/listings/#{@listing.listing_id}"
          expect(current_path).to eq "/listings/#{@listing.listing_id}"
          expect(page).to have_content 'Example title'
          expect(page).to have_content 'Example Description'
          expect(page).to have_content 'Example Location'
          expect(page).to have_content '£10'
          expect(page).to have_content 'Example'
          expect(page).to have_content 'Collection,Postal Delivery'
          expect(page).to have_content 'Cash,Bank Transfer'
          expect(page).to have_content 'Used'
          expect(page).to have_xpath "//img[contains(@src,'image-placeholder.png')]"
          expect(page).to have_button 'Contact Seller'
          expect(page).to have_link 'Report this item'
          expect(page).to_not have_link 'Edit'
          expect(page).to have_content 'This listing is awaiting moderation'
        end
      end
    end
  end

  context "As a logged in moderator" do

    before do
      login_as(@mod_user, scope: :user)
    end

    specify "I can see a link for the moderator dashboard" do
      visit '/'
      expect(page).to have_content 'Moderator Dashboard'
    end

    specify "I can access the moderator dashboard from the link" do
      visit '/'
      click_link 'navbar-moderator-link'
      expect(current_path).to eq '/moderator'
    end

    specify "I can access the moderator dashboard by URL" do
      visit '/moderator'
      expect(current_path).to eq '/moderator'
    end

    specify "I can access the moderation queue by URL" do
      visit '/listing_review'
      expect(current_path).to eq '/listing_review'
    end

    context 'A new listing has been created' do

      before do
        @listing = FactoryBot.create :listing_content, title: 'Example title', description: 'Example Description', price: 10.0, category: (FactoryBot.create :category, name: 'Example'), location: 'Example Location', condition: 'Used', delivery_options: '["Collection","Postal Delivery"]', payment_options: '["Cash","Bank Transfer"]', listing_id: (FactoryBot.create :listing, user: @user).id
      end

      specify 'I cannot view a new listing that has not been approved' do
        visit "listings/#{@listing.listing_id}"
        expect(current_path).to eq '/'
        expect(page).to have_content "This listing is not available for viewing"
      end

      specify "I cannot edit a listing that isn't my own" do
        @listing.update(approved: true)
        visit "listings/#{@listing.listing_id}"
        expect(page).to have_button 'Contact Seller'
        expect(page).to have_link 'Report this item'
        expect(page).to have_link 'Edit'
      end

      context 'An edit has been made to the approved listing' do

        before do
          @listing.update(approved: true)
          FactoryBot.create :listing_content, title: 'Another example title', description: 'Example Description', price: 10.0, category: (FactoryBot.create :category, name: 'Example2'), location: 'Example Location', condition: 'Used', delivery_options: '["Collection","Postal Delivery"]', payment_options: '["Cash","Bank Transfer"]', listing_id: @listing.listing_id
        end

        specify "I can only view the most recent approved edit to the listing" do
          visit "listings/#{@listing.listing_id}"
          expect(page).to have_content 'Example title'
          expect(page).to have_content 'Example Description'
          expect(page).to have_content 'Example Location'
          expect(page).to have_content 'Example'
          expect(page).to have_content '£10'
          expect(page).to have_content 'Used'
          expect(page).to have_content 'Collection,Postal Delivery'
          expect(page).to have_content 'Cash,Bank Transfer'
          expect(page).to have_button 'Contact Seller'
          expect(page).to have_link 'Report this item'
          expect(page).to have_link 'Edit'
          expect(page).to have_content 'This listing is awaiting moderation'
        end
      end
    end
  end  
end