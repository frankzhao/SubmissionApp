class MarkingCategoriesController < ApplicationController
  before_filter :require_logged_in
  before_filter :require_permission

  def require_permission
    p "Current user is admin: ", current_user.is_admin
    return if current_user.is_admin
    @assignment = Assignment.find(params[:assignment_id])
    unless @assignment.group_type.conveners.include? current_user
      flash[:errors] = ["You don't have permission to do that with assignments."]
      redirect_to @assignment
    end
  end

  def create
    category = MarkingCategory.new(params[:marking_category])
    category.assignment_id = Assignment.find(params[:assignment_id]).id
    if ! category.save
      flash[:errors] = category.errors.full_messages
    end
    redirect_to assignment_marking_categories_url(params[:assignment_id])
  end

  def update
    category = MarkingCategory.find(params[:id])
    category.update_attributes(params[:marking_category])
    if category.save
      flash[:errors] = category.errors.full_messages
    else
      flash[:errors] = category.errors.full_messages
    end
    redirect_to assignment_marking_categories_url(category.assignment)
  end

  def destroy
    category = MarkingCategory.find(params[:id])

    category.destroy
    redirect_to assignment_marking_categories_url(category.assignment)
  end

  def index
    @assignment = Assignment.find(params[:assignment_id])
    @marking_categories = @assignment.marking_categories
    render :index
  end
end