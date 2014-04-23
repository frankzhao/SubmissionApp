class CustomBehaviorsController < ApplicationController
  def index
    @assignment = Assignment.find(params[:assignment_id])
    @custom_behaviors = @assignment.custom_behaviors
  end

  def create
    @custom_behavior = CustomBehavior.new(params[:behavior])
    @custom_behavior.assignment_id = Assignment.find(params[:assignment_id]).id

    unless @custom_behavior.save
      flash[:errors] = @custom_behavior.errors.full_messages
    end

    redirect_to :back
  end

  def update
    @custom_behavior = CustomBehavior.find(params[:id])
    @custom_behavior.update_attributes(params[:behavior])
    redirect_to :back
  end

  def destroy
    @custom_behavior = CustomBehavior.find(params[:id])
    @custom_behavior.destroy
    flash[:notifications] = ["Custom behavior successfully destroyed"]
    redirect_to :back
  end
end
