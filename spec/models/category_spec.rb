# == Schema Information
#
# Table name: categories
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(TRUE)
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

RSpec.describe Category, type: :model do
  describe "#new" do
    it "is valid with valid attributes" do
      expect(Category.new(name: "name")).to be_valid
    end

    it "is not valid without name attribute" do
      expect(Category.new(name: nil)).to_not be_valid
    end
  end

  describe "#exists" do
    it "returns true if category with given name exists" do
      Category.create(name: "test")
      expect(Category.exists? "test").to be true
    end

    it "returns false if categor with given name does not exist" do
      expect(Category.exists? "some_definitely_non_existing_category").to be false
    end
  end

  describe "#get_all" do
    it "returns an empty list if there are no listings" do
      expect(Category.get_all).to eq []
    end

    it "returns all active categories" do
      categories = [
        FactoryBot.create(:category, name: "cat1"),
        FactoryBot.create(:category, name: "cat2"),
        FactoryBot.create(:category, name: "cat3"),
      ]
      all_categories = Category.get_all

      categories.each do |category|
        expect(all_categories).to include category
      end
    end

    it "does not return innactive categories" do
      categories = [
        FactoryBot.create(:category, name: "cat1", active: false),
        FactoryBot.create(:category, name: "cat2", active: false),
        FactoryBot.create(:category, name: "cat3", active: false),
      ]
      all_categories = Category.get_all

      categories.each do |category|
        expect(all_categories).to_not include category
      end
    end
  end

  describe "#deactivate!" do
    it "sets the 'active' field of a category to false" do
      category = Category.create(name: "test")
      category.deactivate!
      category.reload

      expect(category.active).to be false
    end

    it "removes the category from any listings associated with the category" do
      category = Category.create(name: "test")
      listing = FactoryBot.create(:listing, user: FactoryBot.create(:user))
      listing_content = FactoryBot.create(:listing_content, listing: listing, category: category)

      category.deactivate!
      listing_content.reload

      expect(listing_content.category.name).to eq "[Removed Category]"
    end
  end
end
