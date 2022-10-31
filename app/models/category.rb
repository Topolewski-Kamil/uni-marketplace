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
class Category < ApplicationRecord
  validates :name, presence: true

  # get all active categories (except 'Removed_Category')
  def self.get_all
    Category.where(active: true)
  end

  def self.exists?(name)
    duplicate = Category.find_by(name: name, active: true)
    return duplicate.present?
  end

  # deactivates category
  def deactivate!
    self.name = "[Removed Category]"
    self.active = false
    self.save
  end
end
