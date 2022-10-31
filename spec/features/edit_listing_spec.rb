require 'rails_helper'

describe "Edit Listings" do

  before do
    user = FactoryBot.create :user, moderator: true
    login_as(user, scope: :user)
    category1 = FactoryBot.create :category, name: 'Example 1'
    category2 = FactoryBot.create :category, name: 'Example 2'
    @listing_content = FactoryBot.create :listing_content, title: 'Example title', description: 'Example Description', price: 5.0, category: category1, location: 'International', condition: 'Well Used', delivery_options: '["Collection","Postal Delivery"]', payment_options: '["Cash","Bank Transfer"]', listing_id: (FactoryBot.create :listing, user: user).id, approved: true
    images = [ActionDispatch::Http::UploadedFile.new({filename: "test-image-1.jpg", type: "image/jpeg", tempfile: Tempfile.new('edit_listing_spec-test-image-1'), head: 'test_headers'})]
    @listing_content.images.attach(images)
  end

  specify 'I can access the edit page from the listing viewing page' do
    visit "/listings/#{@listing_content.listing_id}"
    click_link 'Edit'
    expect(current_path).to eq "/listings/#{@listing_content.listing_id}/edit"
  end

  specify 'I can see all fields filled in with the current data' do
    visit "/listings/#{@listing_content.listing_id}/edit"
    expect(find_field('Title').value).to eq 'Example title'
    expect(page).to have_content 'Example Description'
    expect(find_field('Price').value).to eq '5.0'
    expect(page).to have_content 'International'
    expect(page).to have_select 'Category', selected: 'Example 1'
    expect(page).to have_xpath("//img[contains(@src,'test-image-1.jpg')]")
    expect(page).to have_checked_field 'listing_content_delivery_options_collection'
    expect(page).to have_checked_field 'listing_content_delivery_options_postal_delivery'
    expect(page).to have_unchecked_field 'listing_content_delivery_options_in_person_delivery'
    expect(page).to have_checked_field 'listing_content_payment_options_cash'
    expect(page).to have_unchecked_field 'listing_content_payment_options_paypal'
    expect(page).to have_checked_field 'listing_content_payment_options_bank_transfer'
    expect(page).to have_select 'Condition', selected: 'Well Used'
  end

  specify 'I cannot update a listing with empty inputs for the non-optional fields' do
    visit "/listings/#{@listing_content.listing_id}/edit"
    fill_in 'Title', with: ''
    fill_in 'Description', with: ''
    fill_in 'Price', with: ''
    page.select '', from: 'Category'
    page.select 'Sheffield', from: 'Location'
    fill_in 'Postal Code (First 3 characters)', with: 's10'
    page.uncheck 'listing_content_delivery_options_collection'
    page.uncheck 'listing_content_delivery_options_postal_delivery'
    page.find('#edit-button', visible: false).click
    expect(page).to have_content 'Edition unsuccessful, some of the non-optional details were blank or invalid'
    expect(current_path).to eq "/listings/#{@listing_content.listing_id}/edit"
    expect(find_field('Title').value).to eq 'Example title'
    expect(page).to have_content 'Example Description'
    expect(find_field('Price').value).to eq '5.0'
    expect(page).to have_content 'International'
    expect(page).to have_select 'Category', selected: 'Example 1'
    expect(page).to have_xpath("//img[contains(@src,'test-image-1.jpg')]")
    expect(page).to have_checked_field 'listing_content_delivery_options_collection'
    expect(page).to have_checked_field 'listing_content_delivery_options_postal_delivery'
    expect(page).to have_unchecked_field 'listing_content_delivery_options_in_person_delivery'
    expect(page).to have_checked_field 'listing_content_payment_options_cash'
    expect(page).to have_unchecked_field 'listing_content_payment_options_paypal'
    expect(page).to have_checked_field 'listing_content_payment_options_bank_transfer'
    expect(page).to have_select 'Condition', selected: 'Well Used'
  end

  specify 'I cannot update a listing with a negative number for the price' do
    visit "/listings/#{@listing_content.listing_id}/edit"
    fill_in 'Price', with: -40
    page.find('#edit-button', visible: false).click
    expect(current_path).to eq "/listings/#{@listing_content.listing_id}/edit"
    expect(page).to have_content "Edition unsuccessful, some of the non-optional details were blank or invalid"
    expect(find_field('Price').value).to eq '5.0'
  end

  specify "I can select a photo from my listing for deletion" do
    visit "/listings/#{@listing_content.listing_id}/edit"
    click_link "image_link#{@listing_content.images[0].id}"
    expect(current_path).to eq "/listings/#{@listing_content.listing_id}/edit"
    expect(page).to have_content "Image was removed from the listing"
    expect(page).to_not have_xpath("//img[contains(@src,'test-image-1.jpg')]")
  end

  specify "I can select multiple photos from my listing for deletion" do
    @listing_content.images.attach(ActionDispatch::Http::UploadedFile.new({filename: "test-image-2.png", type: "image/png", tempfile: Tempfile.new('edit_listing_spec-test-image-2'), head: 'test_headers2'}))
    visit "/listings/#{@listing_content.listing_id}/edit"
    click_link "image_link#{@listing_content.images[1].id}"
    expect(page).to have_xpath("//img[contains(@src,'test-image-1.jpg')]")
    expect(page).to_not have_xpath("//img[contains(@src,'test-image-2.png')]")
    click_link "image_link#{@listing_content.images[0].id}"
    expect(current_path).to eq "/listings/#{@listing_content.listing_id}/edit"
    expect(page).to have_content "Image was removed from the listing"
    expect(page).to_not have_xpath("//img[contains(@src,'test-image-1.jpg')]")
    expect(page).to_not have_xpath("//img[contains(@src,'test-image-2.png')]")
  end

  context "Updating aspects of my listing" do

    context "There are images in the listing" do
      before do
        visit "/listings/#{@listing_content.listing_id}/edit"
        fill_in 'Title', with: 'New example title'
        fill_in 'Description', with: 'New example description'
        fill_in 'Price', with: 7.00
        page.select 'Example 2', from: 'Category'
        page.select 'UK', from: 'Location'
        page.uncheck 'listing_content_delivery_options_collection'
        page.uncheck 'listing_content_delivery_options_postal_delivery'
        page.check 'listing_content_delivery_options_in_person_delivery'
        page.select 'New', from: 'Condition'
        page.uncheck 'listing_content_payment_options_cash'
        page.check 'listing_content_payment_options_paypal'
      end
  
      specify 'I can update all fields of my listing and all photos will be kept' do
       page.find('#edit-button', visible: false).click
        expect(current_path).to eq "/listings/#{@listing_content.listing_id}"
        expect(page).to have_content 'Listing edition successful, awaiting approval by moderators'
        visit "/listing_review?clicked_listing_id=#{@listing_content.listing_id}"
        expect(page).to have_content 'New example title'
        expect(page).to have_content 'New example description'
        expect(page).to have_content '7.00'
        expect(page).to have_content 'UK'
        expect(page).to have_content 'Example 2'
        expect(page).to have_content 'In Person Delivery'
        expect(page).to have_content 'Bank Transfer, Paypal'
        expect(page).to have_content 'New'
        expect(page).to have_xpath("//img[contains(@src,'test-image-1.jpg')]")
      end
  
      specify 'I can add photos to my listing as well as existing photos' do
        page.attach_file "listing_content[new_images][]", [Rails.root + "spec/testing-assets/images/test-image-2.png"]
        page.find('#edit-button', visible: false).click
        expect(page).to have_content 'Listing edition successful, awaiting approval by moderators'
        visit "/listing_review?clicked_listing_id=#{@listing_content.listing_id}"
        expect(page).to have_xpath("//img[contains(@src,'test-image-1.jpg')]")
        expect(page).to have_xpath("//img[contains(@src,'test-image-2.png')]")
      end
    end

    specify 'I can add photos to my listing if none currently exist' do
      ActiveStorage::Attachment.find(@listing_content.images[0].id).purge
      visit "/listings/#{@listing_content.listing_id}/edit"
      page.attach_file "listing_content[new_images][]", [(Rails.root + "spec/testing-assets/images/test-image-1.jpg"),(Rails.root + "spec/testing-assets/images/test-image-2-small.png")]
      page.find('#edit-button', visible: false).click
      expect(page).to have_content 'Listing edition successful, awaiting approval by moderators'
      visit "/listing_review?clicked_listing_id=#{@listing_content.listing_id}"
      expect(page).to have_xpath("//img[contains(@src,'test-image-1.jpg')]")
      expect(page).to have_xpath("//img[contains(@src,'test-image-2-small.png')]")
    end

    specify 'Images are only deleted once the form has been submitted' do
      visit "/listings/#{@listing_content.listing_id}/edit"
      click_link "image_link#{@listing_content.images[0].id}"
      expect(current_path).to eq "/listings/#{@listing_content.listing_id}/edit"
      expect(page).to have_content "Image was removed from the listing"
      expect(page).to_not have_xpath("//img[contains(@src,'test-image-1.jpg')]")
      visit "/listings/#{@listing_content.listing_id}/edit"
      expect(page).to have_xpath("//img[contains(@src,'test-image-1.jpg')]")
      visit "/listings/#{@listing_content.listing_id}"
      expect(page).to have_xpath("//img[contains(@src,'test-image-1.jpg')]")
    end
  end
end