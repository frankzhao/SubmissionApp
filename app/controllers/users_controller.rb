class UsersController < ApplicationController
  before_filter :require_logged_in

  def new
    @course = Course.find(params[:course_id])
    if current_user.is_admin or current_user == @course.convenor
      render :new
    else
      flash[:errors] = ["You have to be an admin or the convenor of this course to create users"]
      redirect_to course_url(@course)
    end
  end

  def create
    @course = Course.find(params[:course_id])
    if current_user.is_admin or current_user == @course.convenor
      @course.add_students_by_csv(params[:user_details])
      redirect_to course_url(@course)
    else
      flash[:errors] = ["You have to be an admin or the convenor of this course to create users"]
      redirect_to course_url(@course)
    end
  end

  def show
    @user = User.find(params[:id])
    @student_courses = @user.student_courses
    @staffed_courses = @user.staffed_courses
    @convened_courses = @user.convened_courses
    render :show
  end
end
