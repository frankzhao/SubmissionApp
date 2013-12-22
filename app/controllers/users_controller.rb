class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @student_courses = @user.student_courses
    @staffed_courses = @user.staffed_courses
    @convened_courses = @user.convened_courses
    render :show
  end
end
