class SubmissionFilesController < ApplicationController
  before_filter :require_logged_in

  def serve
    file = SubmissionFile.find(params[:id])
    submission = file.assignment_submission
    relationship = submission.relationship_to_user(current_user)
    if relationship
      response.headers['Content-Disposition'] = "attachment; filename=\"#{file.name}\""
      send_data(file.file_blob)
    else
      render "/"
      flash[:errors] = ["You don't have permission to access that file."]
    end
  end
end
