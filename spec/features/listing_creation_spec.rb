require "rails_helper"

describe "Listing Creation" do
  def fill_in_add_listing_form_page_1(title: "Testing_title",
                                      description: "Testing_description",
                                      category: "Book",
                                      price: 7.99,
                                      location: "UK",
                                      postcode: "S10",
                                      delivery: ["Postal Delivery"])
    visit "/listings/new"
    fill_in "Title", with: title
    fill_in "Description", with: description
    select category, from: "Category"
    fill_in "Price", with: price
    select location, from: "Location"

    ListingContent::DELIVERY_OPTIONS.each do |method|
      unselect method, from: "Delivery options"
    end
    delivery.each do |method|
      select method, from: "Delivery options"
    end

    if location == "Sheffield"
      fill_in "Postal Code (First 3 characters)", with: postcode
    end
  end

  def fill_in_add_listing_form_page_2(condition: "New",
                                      payment: ["Cash"],
                                      images: [Rails.root + "spec/testing-assets/images/test-image-1.jpg"])
    select condition, from: "Condition"

    ListingContent::PAYMENT_OPTIONS.each do |method|
      unselect method, from: "Payment options"
    end
    payment.each do |method|
      select method, from: "Payment options"
    end

    page.attach_file "listing[images][]", images

    check "listing_terms"
  end

  def fill_in_form(title: "Testing_title",
                               description: "Testing_description",
                               category: "Book",
                               price: 7.99,
                               location: "UK",
                               postcode: "S10",
                               delivery: ["Postal Delivery"],
                               condition: "New",
                               payment: ["Cash"],
                               images: [Rails.root + "spec/testing-assets/images/test-image-1.jpg"])
    fill_in_add_listing_form_page_1(title: title, description: description, category: category, price: price, location: location, postcode: postcode, delivery: delivery)
    click_button "Next"
    fill_in_add_listing_form_page_2(condition: condition, payment: payment, images: images)
  end

  before do
    user = FactoryBot.create(:user, givenname: "Name", sn: "Surname")
    login_as(user, scope: :user)

    FactoryBot.create :category, name: "Book"
    FactoryBot.create :category, name: "Film"
  end

  context "Form page 1", js: true do
    before do
      visit "/listings/new"
    end

    specify "I cannot click the next button with no fields filled in" do
      expect(page).to have_button("Next", disabled: true)
    end

    specify "I can view all of the first page (required) inputs" do
      expect(page).to have_content "Title"
      expect(page).to have_content "Description"
      expect(page).to have_content "Category"
      expect(page).to have_content "Price"
      expect(page).to have_content "Location"
      expect(page).to have_content "Delivery options"
    end

    specify "I cannot view the second page inputs from the first page" do
      expect(page).to_not have_content "Condition"
      expect(page).to_not have_content "Payment options"
      expect(page).to_not have_content "Images"
      expect(page).to_not have_content "Terms and Conditions"
    end

    specify "Once I fill in all the form fields I can click the next button to get to the next page." do
      fill_in_add_listing_form_page_1()
      click_button "Next"
      expect(page).to have_content "Optional Details"
    end

    context "Input validation" do
      specify "I cannot add a listing without a title." do
        fill_in_add_listing_form_page_1(title: "")
        expect(page).to have_button("Next", disabled: true)
      end

      context "description" do
        specify "I cannot add a listing without a description" do
          fill_in_add_listing_form_page_1(description: "")
          expect(page).to have_button("Next", disabled: true)
        end

        specify "I cannot add a listing with a description longer than 2000 chars." do
          fill_in_add_listing_form_page_1(description: ("p" * 2001))
          expect(find_field("Description").value).to_not eq ("p" * 2001)
        end
      end

      context "price" do
        specify 'I cannot add a listing with a price that isn\'t a number.' do
          fill_in_add_listing_form_page_1(price: "pp")
          expect(find_field("Price").value).to_not eq "pp"
        end

        specify "I cannot add a listing with a price that is larger than £10000." do
          fill_in_add_listing_form_page_1(price: 10001)
          expect(find_field("Price").value).to_not eq 10001
        end

        specify "I cannot add a listing with a price that is negative." do
          fill_in_add_listing_form_page_1(price: -1)
          expect(find_field("Price").value).to_not eq -1
        end
      end

      context "location" do
        specify "When I select Sheffield I can add the first 3 digits of my postcode." do
          select "Sheffield", from: "Location"
          expect(page).to have_content "Postal Code (First 3 characters)"
        end

        specify "When I select UK or International I do not have an input for the postcode." do
          select "UK", from: "Location"
          expect(page).to_not have_content "Postal Code (First 3 characters)"
          select "International", from: "Location"
          expect(page).to_not have_content "Postal Code (First 3 characters)"
        end

        specify "I cannot add an invalid postcode format." do
          fill_in_add_listing_form_page_1()
          select "Sheffield", from: "Location"

          fill_in "Postal Code (First 3 characters)", with: "111"
          expect(page).to have_content "Invalid post code"

          fill_in "Postal Code (First 3 characters)", with: "SSS"
          expect(page).to have_content "Invalid post code"
        end

        specify "I cannot add a postcode prefix that is outside sheffield." do
          fill_in_add_listing_form_page_1()
          select "Sheffield", from: "Location"

          fill_in "Postal Code (First 3 characters)", with: "MK20"
          expect(page).to have_content "Invalid post code"

          fill_in "Postal Code (First 3 characters)", with: "B2"
          expect(page).to have_content "Invalid post code"
        end

        specify "I can add a postcode that is within Sheffield." do
          fill_in_add_listing_form_page_1()
          select "Sheffield", from: "Location"

          fill_in "Postal Code (First 3 characters)", with: "S1"
          expect(page).to_not have_content "Invalid post code"
          expect(page).to have_button("Next")

          fill_in "Postal Code (First 3 characters)", with: "S30"
          expect(page).to_not have_content "Invalid post code"
          expect(page).to have_button("Next")
        end

        specify "I can add the listing when there is no location selected." do
          fill_in_add_listing_form_page_1()
          select "Sheffield", from: "Location"

          fill_in "Postal Code (First 3 characters)", with: ""
          expect(page).to have_button("Next")
        end
      end

      context "Delivery options" do
        specify "I cannot add the listing with no delivery options selected." do
          fill_in_add_listing_form_page_1(delivery: [])
          expect(page).to have_button("Next", disabled: true)
        end

        specify "I can add the listing with only one of the delivery options selected." do
          fill_in_add_listing_form_page_1(delivery: ["Postal Delivery"])
          expect(page).to have_button("Next")
        end

        specify "I can add the listing with multiple delivery options selected." do
          fill_in_add_listing_form_page_1(delivery: ["Postal Delivery", "Collection", "In Person Delivery"])
          expect(page).to have_button("Next")
        end
      end
    end
  end

  context "Form page 2", js: true do
    before do
      fill_in_add_listing_form_page_1()
      click_button "Next"
    end

    specify "I cannot see any of the page 1 elements when on the second page." do
      expect(page).to_not have_content "Title"
      expect(page).to_not have_content "Description"
      expect(page).to_not have_content "Category"
      expect(page).to_not have_content "Price"
      expect(page).to_not have_content "Location"
      expect(page).to_not have_content "Delivery options"
    end

    specify "I can see all of the 2nd page input fields." do
      expect(page).to have_content "Condition"
      expect(page).to have_content "Payment options"
      expect(page).to have_content "Images"
      expect(page).to have_content "Terms and Conditions"
    end

    specify "I can go back to the first page and view all the information I put there." do
      click_button "Back"
      expect(find_field("Title").value).to eql "Testing_title"
      expect(find_field("Description").value).to eql "Testing_description"
      expect(find_field("Category").value).to eql "Book"
      expect(find_field("Price").value).to eql "7.99"
      expect(find_field("location").value).to eql "UK"
    end

    specify "I cannot submit before accepting the terms and service." do
      expect(page).to have_button("Save Listing", disabled: true)
      check "listing_terms"
      expect(page).to have_button("Save Listing")
    end

    specify "I can edit info on the first page and retain info on the second page." do
      fill_in_add_listing_form_page_2(condition: "New")
      click_button "Back"
      fill_in "Title", with: "Testing2"
      click_button "Next"
      expect(find_field("Condition").value).to eql "New"
      expect(page).to have_button("Save Listing")
    end

    context "Input Validation" do
      context "condition" do
        specify "I can set a condition" do
          fill_in_add_listing_form_page_2(condition: "Slightly Used")
          expect(page).to have_button("Save Listing")
        end
      end

      context "payment options" do
        specify "I can select a payment option." do
          fill_in_add_listing_form_page_2(payment: ["Bank Transfer"])
          expect(page).to have_button("Save Listing")
        end
        specify "I can select multiple payment options." do
          fill_in_add_listing_form_page_2(payment: ["Cash", "Bank Transfer"])
          expect(page).to have_button("Save Listing")
        end
      end

      context "images" do
        specify "I can add an image to a listing." do
          fill_in_add_listing_form_page_2()
          expect(page).to have_button("Save Listing")
        end

        specify "I can add multiple images to a listing." do
          fill_in_add_listing_form_page_2(
            images: [Rails.root + "spec/testing-assets/images/test-image-1.jpg",
                     Rails.root + "spec/testing-assets/images/test-image-2-small.png"],
          )
          expect(page).to_not have_content "MAXIMUM UPLOAD SIZE EXCEEDED"
          expect(page).to have_button("Save Listing")
        end

        specify "I cannot add more than 5 images to a listing." do
          fill_in_add_listing_form_page_2(
            images: [Rails.root + "spec/testing-assets/images/test-image-1.jpg",
                     Rails.root + "spec/testing-assets/images/test-image-1.jpg",
                     Rails.root + "spec/testing-assets/images/test-image-1.jpg",
                     Rails.root + "spec/testing-assets/images/test-image-1.jpg",
                     Rails.root + "spec/testing-assets/images/test-image-1.jpg",
                     Rails.root + "spec/testing-assets/images/test-image-1.jpg"],
          )
          expect(page).to have_content "MAXIMUM IMAGE COUNT EXCEEDED"
          expect(page).to_not have_button("Save Listing")
        end

        specify "I cannot add more than 500KB of image files to the listing." do
          fill_in_add_listing_form_page_2(
            images: [Rails.root + "spec/testing-assets/images/test-image-1.jpg",
                     Rails.root + "spec/testing-assets/images/test-image-1.jpg",
                     Rails.root + "spec/testing-assets/images/test-image-1.jpg",
                     Rails.root + "spec/testing-assets/images/test-image-1.jpg",
                     Rails.root + "spec/testing-assets/images/test-image-1.jpg"],
          )
          expect(page).to have_content "MAXIMUM UPLOAD SIZE EXCEEDED"
          expect(page).to_not have_button("Save Listing")
        end

        specify "I cannot add an image with the wrong file format." do
          fill_in_add_listing_form_page_2(
            images: [Rails.root + "spec/testing-assets/text/test.txt"],
          )
          expect(page).to have_content "Ilegal file type. Allowed formats: png, jpg."
          expect(page).to_not have_button("Save Listing")
        end
      end

      specify "I can do none of the optional items and still submit the listing." do
        fill_in_form()
        pending("This test is broken due to cancancan being hot garbage.")
        fail
        # click_button "Save Listing"
        # expect(page).to_not have_content 'Listing was successfully created.'
      end
    end
  end
end
