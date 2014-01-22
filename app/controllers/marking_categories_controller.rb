class MarkingCategoriesController < ApplicationController
  before_filter :require_logged_in
  before_filter :require_permission

  def require_permission
    @assignment = Assignment.find(params[:assignment_id])
    unless @assignment.group_type.conveners.include? current_user
      flash[:errors] = ["You don't have permission to do that with assignments."]
      redirect_to @assignment
    end
  end

  def create
    category = MarkingCategory.new(params[:marking_category])
    category.assignment_id = params[:assignment_id]
    render :json => category
  end

  def update
    category = MarkingCategory.find(params[:id])
    category.update_attributes(params[:marking_category])
    if category.save
      render :json => category
    else
      render :json => category.errors.full_messages
    end
  end

  def destroy
    category = MarkingCategory.find(params[:id])

    if category.destroy
      render :json => category
    else
      render :json => category.errors.full_messages
    end
  end

  def index
    assignment = Assignment.find(params[:assignment_id])
    render :json => assignment.marking_categories
  end
end