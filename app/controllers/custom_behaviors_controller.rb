class CustomBehaviorsController < ApplicationController
  def index
    @assignment = Assignment.find(params[:assignment_id])
    @custom_behaviors = @assignment.custom_behaviors
  end

  def create
    @custom_behavior = CustomBehavior.new(params[:custom_behavior])
    @custom_behavior.assignment_id = params[:assignment_id]

    unless @custom_behavior.save
      flash[:errors] = @custom_behavior.errors.full_messages
    end

    redirect_to :back
  end

  def create
    @peer_review_cycle = PeerReviewCycle.new(params[:peer_review_cycle])
    # TODO: I don't know why the rhs of this can't be just params[:assignment_id]
    @peer_review_cycle.assignment_id = Assignment.find(params[:assignment_id]).id

    if @peer_review_cycle.save
      redirect_to assignment_cycles_url(params[:assignment_id])
    else
      flash[:errors] = @peer_review_cycle.errors.full_messages
      redirect_to assignment_cycles_url(params[:assignment_id])
    end
  end

  def update
    @peer_review_cycle = PeerReviewCycle.find(params[:id])
    @peer_review_cycle.update_attributes(params[:peer_review_cycle])
    redirect_to assignment_cycles_url(params[:assignment_id])
  end

  def delete
    @peer_review_cycle = PeerReviewCycle.find(params[:id])
    @peer_review_cycle.delete_children
    @peer_review_cycle.destroy
    redirect_to assignment_cycles_url(params[:assignment_id])
  end
end
