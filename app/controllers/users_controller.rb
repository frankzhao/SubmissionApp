class UsersController < ApplicationController
  before_filter :require_logged_in

  def new
    @course = Course.find(params[:course_id])
    if current_user.is_admin or current_user == @course.convener
      render :new
    else
      flash[:errors] = ["You have to be an admin or the convener of this course to create users"]
      redirect_to course_url(@course)
    end
  end

  def create
    @course = Course.find(params[:course_id])
    if current_user.is_admin or current_user == @course.convener
      # begin

        @course.add_students_by_csv(params[:user_details])
        @course.add_staff_by_csv(params[:staff_details])
        redirect_to course_url(@course)
      # rescue => e
      #   flash[:errors] = [e.to_s]
      #   redirect_to :back
      # end
    else
      flash[:errors] = ["You have to be an admin or the convener of this course to create users"]
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

  def index
    redirect_to "/" unless current_user.is_admin
    @users = User.all
    render :index
  end
end
