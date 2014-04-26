class CommentsController < ApplicationController
  def create
    @comment = Comment.new(params[:comment])
    @comment.user = current_user
    @comment.assignment_submission = AssignmentSubmission.find(params[:assignment_submission_id])

    unless @comment.assignment_submission.relationship_to_user(current_user)
      flash[:errors] = ["You don't have permission to comment on that assigment."]
      redirect_to "/"
      return
    end

    cycle = @comment.assignment_submission.which_peer_review_cycle(current_user)
    @comment.peer_review_cycle_id = cycle.id if cycle

    if @comment.assignment_submission.user == current_user
      @comment.mark = nil
    end

    if @comment.save
      params[:mark] && params[:mark].each do |category_id, value|
        next if value == ""
        mark = Mark.new(:comment_id => @comment.id,
                        :marking_category_id => category_id,
                        :value => value)
        if mark.marking_category.relevant_to_user(@comment.assignment_submission,
                                                  current_user)
          unless mark.save
            flash[:errors] = mark.errors.full_messages
            redirect_to :back
            return
          end
        else
          raise "You tried to access a mark you don't have access to"
        end
      end

      if params[:peer_mark] && params[:peer_mark].length > 0
        #TODO: checks
        peer_mark = PeerMark.new(:comment_id => @comment.id,
                                 :value => params[:peer_mark])
        unless peer_mark.save
          redirect_to :back
          flash[:errors] = peer_mark.errors.full_messages
          return
        end
      end

      if (params[:upload] and params[:upload]["datafile"])
        @comment.file_name = params[:upload]["datafile"].original_filename
        @comment.has_file = true
        @comment.save!

        @comment.save_data(params[:upload]["datafile"].read)
      end

      redirect_to :back
    else
      redirect_to :back
      flash[:errors] = @comment.errors.full_messages
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    if @comment.user == current_user || current_user.is_admin_or_convener?
      @comment.destroy
      flash[:notifications] = ["Comment successfully deleted."]
      redirect_to :back
    else
      redirect_to "/"
      flash[:errors] = ["Permission denied"]
      logger.warn("Security warning")
    end
  end

  def get_file
    comment = Comment.find(params[:id])
    submission = comment.assignment_submission
    if submission.permits?(current_user)
      send_file(comment.file_path)
    end
  end
end
