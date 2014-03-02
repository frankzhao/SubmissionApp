class AdminController < ApplicationController
  before_filter :require_convener_or_admin

  def log
    request_text = `cat #{Rails.root.to_s}/log/production.log`

    @requests = request_text.split("\nStarted")

    render :log
  end
end