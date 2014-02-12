class GroupTypesController < ApplicationController
  before_filter :require_logged_in
  before_filter :require_convener_or_admin, :only => [:new, :create, :index]

  def show
    @group_type = GroupType.find(params[:id])
    @courses = @group_type.courses

    render :show
  end

  def new
    @group_type = GroupType.new
    render :new
  end

  def create
    @group_type = GroupType.new
    @group_type.name = params[:group_type][:name]

    ActiveRecord::Base.transaction do
      if @group_type.save
        params[:group_type][:courses].try(:each) do |id|
          GroupCourseMembership.create!(:group_type_id => @group_type.id, :course_id => id)
        end
        redirect_to group_type_url(@group_type)
      else
        flash.now[:errors] = @group_type.errors.full_messages
        render :new
      end
    end
  end

  def edit
    @group_type = GroupType.find(params[:id])
    render :edit
  end

  def update
    @group_type = GroupType.find(params[:id])
    @group_type.name = params[:group_type][:name]
    @group_type.courses.each do |course|
      unless params[:group_type][:courses].include? course.id.to_s
        GroupCourseMembership.find_by_group_type_id_and_course_id(@group_type.id, course.id).delete_all
      end
    end

    params[:group_type][:courses].each do |course_id|
      unless @group_type.courses.include? Course.find(course_id)
        GroupCourseMembership.create!(:group_type_id => @group_type.id, :course_id => course_id)
      end
    end

    if @group_type.save
      redirect_to @group_type
    else
      flash[:errors] = @group_type.errors.full_messages
      redirect_to edit_group_type_url(@group_type)
    end
  end

end