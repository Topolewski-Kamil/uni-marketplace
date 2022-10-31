require "rails_helper"


RSpec.describe "Categories controller", :type => :request do

  before(:each) do
    @user = FactoryBot.create(:moderator)
    login_as(@user)
  end

  ############ ADDING CATEGORIES

  it "adds a new category" do
    headers = { "ACCEPT" => "application/json" }
    post "/categories/add_category/", :params => {:name => "Test Category"}, :headers => headers

    expect(response).to have_http_status(200)
    expect(response.body).to include("Test Category")

    expect(Category.find_by(name: "Test Category")).to_not be_nil
  end

  it "does not add new category when invalid arguments" do
    headers = { "ACCEPT" => "application/json" }

    #no param
    post "/categories/add_category/", :headers => headers
    expect(response).to have_http_status(400)
    expect(response.body).to include("Name is empty")

    #name is empty
    post "/categories/add_category/", :params => {:name => ""}, :headers => headers
    expect(response).to have_http_status(400)
    expect(response.body).to include("Name is empty")

    #name taken
    c = FactoryBot.create :category, name: 'Duplicate'
    post "/categories/add_category/", :params => {:name => "Duplicate"}, :headers => headers
    expect(response).to have_http_status(400)
    expect(response.body).to include("Category with this name already exists")
  end

  ############## DELETING CATEGORY

  it "responds with 400 (bad request) error when deleting category and not providing id" do
    headers = { "ACCEPT" => "application/json" }
    post "/categories/delete_category/", :headers => headers

    expect(response).to have_http_status(400)
  end

  it "responds with 400 (bad request) error when deleting category that doesn't exist" do
    headers = { "ACCEPT" => "application/json" }
    post "/categories/delete_category/", :params => {:id => 0}, :headers => headers

    expect(response).to have_http_status(400)
  end

  it "deletes an existing category" do
    #category to be deleted
    c = FactoryBot.create :category, name: 'DeleteCategory'
    
    #listing associated with the category
    listing = FactoryBot.create :listing_content, category: c, listing_id: (FactoryBot.create :listing, user: @user).id, approved: true

    headers = { "ACCEPT" => "application/json" }
    post "/categories/delete_category/", :params => {:id => c.id}, :headers => headers

    expect(response).to have_http_status(200)
    
    #check if listing's category was changed to fallback category
    listing.reload
    expect(listing.category.name).to match "[Removed Category]"
  end

end