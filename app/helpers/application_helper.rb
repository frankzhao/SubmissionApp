require "anu-ldap"

module ApplicationHelper

  def self.ldap_authenticate(uni_id, password)
    AnuLdap.authenticate(uni_id, password)
  end

  def current_user
    @current_user ||= begin
      user = User.find_by_session_token(session[:session_token])
      if user
        logger.info "Current user is #{user.name}, #{user.uni_id}"
      else
        logger.info "The user isn't logged in"
      end
      user
    end
  end

  def login!(user)
    user.reset_session_token!
    session[:session_token] = user.session_token
  end

  def logout!(user)
    user.reset_session_token!
    session[:session_token] = nil
  end

  def require_logged_in
    unless current_user
      flash[:errors] = ["You have to be logged in to see that"]
      redirect_to new_sessions_url
    end
  end

  def require_convener_or_admin
    unless current_user.is_convener? || current_user.is_admin
      flash[:errors] = ["You have to be a convener or admin to see that"]
      redirect_to courses_url
    end
  end
end
