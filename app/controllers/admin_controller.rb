class AdminController < ApplicationController
  before_filter :require_convener_or_admin

  def log
    errors = `cat #{Rails.root.to_s}/log/production.log`
    render :text => "<pre>#{errors}</pre>"
  end
end