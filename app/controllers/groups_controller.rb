class GroupsController < ApplicationController
  before_filter :require_logged_in
  before_filter :require_permission, :only => [:assignment_show]

  def require_permission
    return if current_user.is_admin

    @assignment = Assignment.find(params[:assignment_id])
    unless @assignment.conveners_and_staff.include?(current_user)
      flash[:errors] = ["You don't have permission to do that with assignments."]
      redirect_to @assignment
    end
  end

  def show
    @group = Group.find(params[:id])
    @group_type = @group.group_type
    @users = @group.students.sort_by!{|x| x.name.split(" ").last}
    @staff = @group.staff
    render :show
  end

  def assignment_show
    @assignment = Assignment.find(params[:assignment_id])
    @group = Group.find(params[:id])
    @students = @group.students.sort_by!{|x| x.name.split(" ").last}
    render :assignment_show
  end

  def assignment_zip
    @assignment = Assignment.find(params[:assignment_id])
    @group = Group.find(params[:id])
    @students = @group.students.sort_by!{|x| x.name.split(" ").last}
    send_file(@group.make_group_zip(@assignment))
  end
end
