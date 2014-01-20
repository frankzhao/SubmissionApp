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
    @peer_review_cycle.assignment_id = params[:assignment_id]

    if @peer_review_cycle.save
      redirect_to assignment_cycles_url(params[:assignment_id])
    else
      @assignment = Assignment.find(params[:assignment_id])
      flash.now[:error] = @peer_review_cycle.errors.full_messages
      render :index
    end
  end

  def activate
    @peer_review_cycle = PeerReviewCycle.find(params[:id])
    @peer_review_cycle.activate!

    flash[:notifications] = ["Peer review cycle successfully activated"]
    redirect_to @peer_review_cycle.assignment
  end
end
