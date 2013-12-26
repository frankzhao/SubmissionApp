class AssignmentsController < ApplicationController
  def show
    @assignment = Assignment.find(params[:id])
    @courses = @assignment.courses
    @user_submissions = @assignment.submissions
                                   .where(:user_id => current_user.id)
    render :show
  end
end
