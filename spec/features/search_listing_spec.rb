require "rails_helper"

describe "Searching" do
  before do
    user = FactoryBot.create :user, sn: "Surname", givenname: "Name"
    user2 = FactoryBot.create :user, sn: "Surname2", givenname: "Name2"
    user3 = FactoryBot.create :user, sn: "Surname2", givenname: "Name2"

    login_as(user, scope: :user)

    category = FactoryBot.create :category, name: "Books", id: 123
    listing = FactoryBot.create :listing, user: user
    listingContent1 = FactoryBot.create :listing_content, title: "Listing_one", price: 1, category: category, approved: true, listing: listing, payment_options: "[\"Paypal\"]", delivery_options: "[\"Collection\"]", condition: "[\"New\"]", location: "[\"UK\"]"

    listing2 = FactoryBot.create :listing, user: user2
    listingContent2 = FactoryBot.create :listing_content, title: "Listing_two", price: 3, category: category, approved: true, listing: listing2, payment_options: "[\"Cash\", \"Swap\"]", delivery_options: "[\"Postal Delivery\", \"Collection\"]", condition: "[\"Well Used\"]", location: "[\"UK\"]"

    category2 = FactoryBot.create :category, name: "Electronics", id: 321
    listing3 = FactoryBot.create :listing, user: user3
    listingContent3 = FactoryBot.create :listing_content, title: "Listing_three", price: 5, category: category2, approved: true, listing: listing3, payment_options: "[\"Swap\"]", delivery_options: "[\"Postal Delivery\"]", condition: "[\"Well Used\"]", location: "[\"International\"]"

    listing4 = FactoryBot.create :listing, user: user2
    listingContent4 = FactoryBot.create :listing_content, title: "Listing_four", price: 5, category: category2, approved: false, listing: listing3, payment_options: "[\"Swap\"]", delivery_options: "[\"Postal Delivery\"]", condition: "[\"Well Used\"]"
  end

  specify "search button reroutes to searching page" do
    visit "/"
    click_button "search-bar-button"
    expect(current_path).to eq "/search"
  end

  specify "when all fields are left blank all listings are shown" do
    visit "/search"
    click_button "Apply filters"
    expect(page).to have_content "Listing_one"
    expect(page).to have_content "Listing_two"
    expect(page).to have_content "Listing_three"
  end

  specify "unapproved listings are not shown" do
    visit "/search"
    click_button "Apply filters"
    expect(page).to_not have_content "Listing_four"
  end

  context "by title" do
    specify "listings where the search term matches their title are shown" do
      visit "/"
      fill_in "Search", with: "Listing_one"
      click_button "search-bar-button"
      expect(page).to have_content "Listing_one"
      expect(page).to_not have_content "Listing_two"
      expect(page).to_not have_content "Listing_three"
    end

    specify "listings containing the search term in the title are shown" do
      visit "/"
      fill_in "Search", with: "Listing"
      click_button "search-bar-button"
      expect(page).to have_content "Listing_one"
      expect(page).to have_content "Listing_two"
      expect(page).to have_content "Listing_three"
    end

    specify "if no listings contain the term then no listings are shown and I see \"No results found\"" do
      visit "/"
      fill_in "Search", with: "Hell hath no fury"
      click_button "search-bar-button"
      expect(page).to have_content "No results found"
      expect(page).to_not have_content "Listing_one"
      expect(page).to_not have_content "Listing_two"
      expect(page).to_not have_content "Listing_three"
    end
  end

  context "by price" do
    specify "when minimum price is set only items above that are shown" do
      visit "/search"
      fill_in "lower_bound_price", with: "3"
      click_button "Apply filters"
      expect(page).to_not have_content "Listing_one"
      expect(page).to have_content "Listing_two"
      expect(page).to have_content "Listing_three"
    end

    specify "when maximum price is set only items below that are shown" do
      visit "/search"
      fill_in "upper_bound_price", with: "4"
      click_button "Apply filters"
      expect(page).to have_content "Listing_one"
      expect(page).to have_content "Listing_two"
      expect(page).to_not have_content "Listing_three"
    end

    specify "when minimum and minumum price is set only items between them are shown" do
      visit "/search"
      fill_in "upper_bound_price", with: "4"
      fill_in "lower_bound_price", with: "3"
      click_button "Apply filters"
      expect(page).to_not have_content "Listing_one"
      expect(page).to have_content "Listing_two"
      expect(page).to_not have_content "Listing_three"
    end
  end

  # Tests removed until the JS testing.
  # context "by payment options" do
  #   specify "only items related to single selected payment option are shown" do
  #     visit "/search"
  #     find(:css, "#payment_options_[value='Cash']").set(true)
  #     click_button "Apply filters"

  #     expect(page).to_not have_content "Listing_one"
  #     expect(page).to have_content "Listing_two"
  #     expect(page).to_not have_content "Listing_three"
  #   end

  #   specify "only items that have one of the selected payment types are shown" do
  #     visit "/search"
  #     find(:css, "#payment_options_[value='Cash']").set(true)
  #     find(:css, "#payment_options_[value='Swap']").set(true)
  #     click_button "Apply filters"

  #     expect(page).to_not have_content "Listing_one"
  #     expect(page).to have_content "Listing_two"
  #     expect(page).to have_content "Listing_three"
  #   end

  #   specify "when there are no items with the selected payment options I should see \"No results found\"" do
  #     visit "/search"
  #     find(:css, "#payment_options_[value='Bank Transfer']").set(true)
  #     click_button "Apply filters"

  #     expect(page).to_not have_content "Listing_one"
  #     expect(page).to_not have_content "Listing_two"
  #     expect(page).to_not have_content "Listing_three"
  #   end
  # end

  # context "by delivery options" do
  #   specify "only items related to single selected delivery option are shown" do
  #     visit "/search"
  #     find(:css, "#delivery_options_[value='Collection']").set(true)
  #     click_button "Apply filters"

  #     expect(page).to have_content "Listing_one"
  #     expect(page).to have_content "Listing_two"
  #     expect(page).to_not have_content "Listing_three"
  #   end

  #   specify "only items that have one of the selected delivery types are shown" do
  #     visit "/search"
  #     find(:css, "#delivery_options_[value='Collection']").set(true)
  #     find(:css, "#delivery_options_[value='Postal Delivery']").set(true)
  #     click_button "Apply filters"

  #     expect(page).to have_content "Listing_one"
  #     expect(page).to have_content "Listing_two"
  #     expect(page).to have_content "Listing_three"
  #   end

  #   specify "when there are no items with the selected delivery options I should see \"No results found\"" do
  #     visit "/search"
  #     find(:css, "#delivery_options_[value='In Person Delivery']").set(true)
  #     click_button "Apply filters"

  #     expect(page).to_not have_content "Listing_one"
  #     expect(page).to_not have_content "Listing_two"
  #     expect(page).to_not have_content "Listing_three"
  #   end
  # end

  # context "by condition" do
  #   specify "only items related to single selected condition are shown" do
  #     visit "/search"
  #     find(:css, "#condition_options_[value='New']").set(true)
  #     click_button "Apply filters"

  #     expect(page).to have_content "Listing_one"
  #     expect(page).to_not have_content "Listing_two"
  #     expect(page).to_not have_content "Listing_three"
  #   end

  #   specify "only items that have one of the selected conditions are shown" do
  #     visit "/search"
  #     find(:css, "#condition_options_[value='New']").set(true)
  #     find(:css, "#condition_options_[value='Well Used']").set(true)
  #     click_button "Apply filters"

  #     expect(page).to have_content "Listing_one"
  #     expect(page).to have_content "Listing_two"
  #     expect(page).to have_content "Listing_three"
  #   end

  #   specify "when there are no items with the selected conditions I should see \"No results found\"" do
  #     visit "/search"
  #     find(:css, "#condition_options_[value='Slightly Used']").set(true)
  #     click_button "Apply filters"

  #     expect(page).to_not have_content "Listing_one"
  #     expect(page).to_not have_content "Listing_two"
  #     expect(page).to_not have_content "Listing_three"
  #   end
  # end

  # context "by location options" do
  #   specify "only items related to single selected location option are shown" do
  #     visit "/search"
  #     find(:css, "#location_options_[value='UK']").set(true)
  #     click_button "Apply filters"

  #     expect(page).to have_content "Listing_one"
  #     expect(page).to have_content "Listing_two"
  #     expect(page).to_not have_content "Listing_three"
  #   end

  #   specify "only items that have one of the selected location are shown" do
  #     visit "/search"
  #     find(:css, "#location_options_[value='UK']").set(true)
  #     find(:css, "#location_options_[value='International']").set(true)
  #     click_button "Apply filters"

  #     expect(page).to have_content "Listing_one"
  #     expect(page).to have_content "Listing_two"
  #     expect(page).to have_content "Listing_three"
  #   end

  #   specify "when there are no items with the selected location options I should see \"No results found\"" do
  #     visit "/search"
  #     find(:css, "#location_options_[value='Sheffield']").set(true)
  #     click_button "Apply filters"

  #     expect(page).to_not have_content "Listing_one"
  #     expect(page).to_not have_content "Listing_two"
  #     expect(page).to_not have_content "Listing_three"
  #   end
  # end
end
