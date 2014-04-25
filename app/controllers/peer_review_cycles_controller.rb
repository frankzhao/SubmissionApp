class PeerReviewCyclesController < ApplicationController
  def index
    #TODO: check permission
    @assignment = Assignment.find(params[:assignment_id])

    @peer_review_cycle = PeerReviewCycle.new
    render :index
  end

  def create
    #TODO: check permission
    @peer_review_cycle = PeerReviewCycle.new(params[:peer_review_cycle])

    # I look the assignment up by its id because it's actually a string of its
    # name, like "assignment-1-wireworld" or whatever, not the primary key.
    @peer_review_cycle.assignment_id = Assignment.find(params[:assignment_id]).id

    p @peer_review_cycle

    if @peer_review_cycle.save
      redirect_to assignment_cycles_url(params[:assignment_id])
    else
      @assignment = Assignment.find(params[:assignment_id])
      flash[:errors] = @peer_review_cycle.errors.full_messages
      redirect_to assignment_cycles_url(params[:assignment_id])
    end
  end

  def activate
    @peer_review_cycle = PeerReviewCycle.find(params[:id])
    begin
      @peer_review_cycle.activate!
    rescue Exception => e
      flash[:errors] = ["Peer review cycle could not be activated. The problem "  +
                        "is probably that there's no acceptable distribution which "+
                        "follows the constraints of no-one getting an assignment "+
                        "which they already had."]
    else
      flash[:notifications] = ["Peer review cycle successfully activated"]
    end


    redirect_to assignment_cycles_url(params[:assignment_id])
  end

  def deactivate
    @peer_review_cycle = PeerReviewCycle.find(params[:id])
    @peer_review_cycle.deactivate!

    flash[:notifications] = ["Peer review cycle successfully deactivated"]
    redirect_to assignment_cycles_url(params[:assignment_id])
  end

  def edit
    @assignment = Assignment.find(params[:assignment_id])
    @peer_review_cycle = PeerReviewCycle.find(params[:id])
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