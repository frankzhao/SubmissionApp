class AssignmentsController < ApplicationController
  before_filter :require_logged_in

  def show
    @assignment = Assignment.find(params[:id])
    @relation = current_user.relationship_to_assignment(@assignment)
    p @relation
    case @relation
    when :student
      @courses = @assignment.courses
      @user_submissions = @assignment.submissions
                                     .where(:user_id => current_user.id)
                                     .order('created_at DESC')
      @permitted_submissions = current_user.permitted_submissions(@assignment)
      render :show_to_student
    when :staff

      @submissions = @assignment.relevant_submissions(current_user)

      render :show_to_staff
    when :convenor
      @submissions = @assignment.relevant_submissions(current_user)
      render :show_to_staff
    end
  end

  # CHECK whether this is idiomatic
  def get_csv
    @assignment = Assignment.find(params[:id])
    render :text => @assignment.marks_csv
  end
end
