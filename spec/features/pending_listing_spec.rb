require "rails_helper"

describe "Pending Listing Moderation" do
  before do
    @user = FactoryBot.create(:user, moderator: true)
    login_as(@user, scope: :user)
  end

  specify "I can see if there are no listings awaiting moderation" do
    visit "/listing_review"
    expect(page).to_not have_css "div#review-listing-list"
    expect(page).to_not have_css "div#review-listing-details"
    expect(page).to have_content "There are no listings awaiting moderation."
  end

  context "There are listings waiting to be moderated" do
    before do
      @category = FactoryBot.create :category, name: "Film"
      @listing1 = FactoryBot.create :listing_content, title: "First test listing", description: "First description", category: @category, location: "First location", delivery_options: '["Collection"]', listing_id: (FactoryBot.create :listing, user: @user).id
      @listing2 = FactoryBot.create :listing_content, title: "Second test listing", description: "Second description", price: 15.25, category: @category, location: "Second location", delivery_options: '["Collection", "Postal Delivery"]', payment_options: '["Bank Transfer"]', condition: "New", listing_id: (FactoryBot.create :listing, user: @user).id
      images = [ActionDispatch::Http::UploadedFile.new({ filename: "test-image-1.jpg", type: "image/jpeg", tempfile: Tempfile.new("pending_listing_spec-test-image-1"), head: "test_headers" }), ActionDispatch::Http::UploadedFile.new({ filename: "test-image-2.png", type: "image/jpeg", tempfile: Tempfile.new("pending_listing_spec-test-image-2"), head: "test_headers2" })]
      @listing2.images.attach(images)
      @listing2.save
    end

    specify "I can view all pending listings for moderation" do
      visit "/listing_review"
      within(:css, "div#review-listing-list") do
        expect(page).to have_content "First test listing"
        expect(page).to have_content "Second test listing"
      end
      within(:css, "div#review-listing-details") do
        expect(page).to have_content "First test listing"
        expect(page).to have_content "None specified"
        expect(page).to have_content "Collection"
        expect(page).to have_content "None specified"
        expect(page).to have_xpath("//img[contains(@src,'image-placeholder.png')]")
      end
    end

    specify "I can select a listing to view it's details" do
      visit "/listing_review"
      click_link("select_listing#{@listing2.listing_id}")
      expect(current_path).to eq "/listing_review"
      within(:css, "div#review-listing-details") do
        expect(page).to have_content "Second test listing"
        expect(page).to have_content "Second description"
        expect(page).to have_content "£15.25"
        expect(page).to have_content "Second location"
        expect(page).to have_content "Collection, Postal Delivery"
        expect(page).to have_content "Bank Transfer"
        expect(page).to have_content "New"
        expect(page).to have_xpath("//img[contains(@src,'test-image-1.jpg')]")
        expect(page).to have_xpath("//img[contains(@src,'test-image-2.png')]")
      end
      within(:css, "div#review-listing-category") do
        expect(page).to have_content "Film"
      end
    end

    specify "I can approve a listing" do
      visit "/listing_review"
      click_link("select_listing#{@listing2.listing_id}")
      click_link("accept_listing#{@listing2.listing_id}")
      expect(current_path).to eq "/listing_review"
      expect(page).to have_content "Listing was accepted"
      within(:css, "div#review-listing-list") do
        expect(page).to_not have_content "Second test listing"
      end
    end

    specify "I can reject a listing" do
      visit "/listing_review"
      click_link("select_listing#{@listing1.listing_id}")
      click_link("reject_listing#{@listing1.listing_id}")
      expect(current_path).to eq "/listing_review"
      expect(page).to have_content "Listing was rejected and deleted"
      within(:css, "div#review-listing-list") do
        expect(page).to_not have_content "First test listing"
      end
    end

    specify "I can see any new listing submissions on the queue list" do
      new_listing = FactoryBot.create(:listing,
                                      user: @user)
      listing_content = FactoryBot.create(:listing_content,
                                          title: "Third test listing",
                                          description: "Third description",
                                          price: 0.0,
                                          category: @category,
                                          location: "UK",
                                          approved: false,
                                          listing: new_listing)
      visit "/listing_review"
      expect(page).to have_content "Third test listing"
    end
  end
end
