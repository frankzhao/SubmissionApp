class ExtensionsController < ApplicationController
  before_filter :require_convener_or_admin

  def index
    @assignment = Assignment.find(params[:assignment_id])
    @extensions = @assignment.extensions.includes(:user)
    @extension = Extension.new
  end

  def destroy
    @extension = Extension.find(params[:id])
    @extension.destroy
    flash[:warnings] = ["Extension successfully removed"]
    redirect_to :back
  end

  def create
    @extension = Extension.new(params[:extension])
    @extension.assignment_id = Assignment.find(params[:assignment_id]).id
    @extension.user = User.find_by_uni_id(params[:student_uni_id])
    if @extension.save
      flash[:notifications] = ["Extension successfully created"]
      redirect_to :back
    else
      flash[:errors] = ["Extension creation was not successful."]
      redirect_to :back
    end
  end
end
