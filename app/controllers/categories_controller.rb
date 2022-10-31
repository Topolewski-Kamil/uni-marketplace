class CategoriesController < ApplicationController
  # Deleting existing category through the model on the dashboard
  def delete_category
    id = params[:id]
    
    if id.nil?
      #puts "[DELETE CATEGORY] : ID is empty"
      respond_to do |format|
          format.json {render status: 400, json: {"success" => false}}
      end
      return
    end
    
    c = Category.find_by(id: id, active: true)
    if c.present?
      c.deactivate!
    
      #puts "[DELETE CATEGORY] : category deleted"
      respond_to do |format|
        format.json {render status: 200, json: {"success" => true, "id" => id}}
      end
    
    else
      #puts "[DELETE CATEGORY] : Category not found"
      respond_to do |format|
        format.json {render status: 400, json: {"success" => false, "id" => id}}
      end
    end
  end


  def add_category
    name = params[:name]
    
    if name.nil? || name.strip.empty?
      #puts "[ADD CATEGORY] : Name is empty"
      respond_to do |format|
        format.json {render status: 400, json: {"success" => false, "reason" => "Name is empty"}}
      end
      return
    end

    name = name.strip
    
    if Category.exists? name
      #puts "[ADD CATEGORY] : Category with given name already exist"
      respond_to do |format|
        format.json {render status: 400, json: {"success" => false, "reason" => "Category with this name already exists"}}
      end
      return
    end
    
    c = Category.create(name: name, active: true)
    new_record = Category.find_by(name: name, active: true)
    
    if new_record.present?
      #puts "[ADD CATEGORY] : New category added"
      respond_to do |format|
        format.json {render status: 200, json: {name: new_record.name, id: new_record.id} }
      end
    
    else
      #puts "[ADD CATEGORY] : Something went wrong when adding new category"
      respond_to do |format|
        format.json {render status: 500, json: {"success" => false, "reason" => "Something went wrong :("}}
      end
    end
  end
end