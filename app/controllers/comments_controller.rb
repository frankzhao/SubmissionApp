class CommentsController < ApplicationController
  def create
    #TODO: check that the person is allowed to comment
    @comment = Comment.new(params[:comment])
    @comment.user = current_user
    @comment.assignment_submission = AssignmentSubmission.find(params[:assignment_submission_id])
    cycle = @comment.assignment_submission.which_peer_review_cycle(current_user)
    @comment.peer_review_cycle_id = cycle.id if cycle

    if @comment.assignment_submission.user == current_user
      @comment.mark = nil
    end
    if @comment.save
      params[:mark] && params[:mark].each do |category_id, value|
        mark = Mark.new(:comment_id => @comment.id,
                        :marking_category_id => category_id,
                        :value => value)
        if mark.marking_category.relevant_to_user(@comment.assignment_submission,
                                                  current_user)
          mark.save!
        else
          raise "You tried to access a mark you don't have access to"
        end
      end

      if params[:peer_mark]
        #TODO: checks
        peer_mark = PeerMark.new(:comment_id => @comment.id,
                                 :value => params[:peer_mark])
        peer_mark.save!
      end

      redirect_to(assignment_assignment_submission_url(params[:assignment_id],
                            params[:assignment_submission_id]))
    else
      redirect_to(assignment_assignment_submission_url(params[:assignment_id],
                            params[:assignment_submission_id]))
      flash[:errors] = @comment.errors.full_messages
    end
  end
end
