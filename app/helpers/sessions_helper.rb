module SessionsHelper

  # Logs in the user
  def log_in(user)
    cookies.signed[:user_id] = user.id
  end

  # Returns true of the given user is the current user.
  def current_user?(user)
    user == current_user
  end

  # Returns current user if any
  def current_user
    @current_user ||= User.find_by(id: cookies.signed[:user_id])
  end

  # Returns current user id
  def current_user_id
    current_user[:id]
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  # Logs out the current user
  def log_out
    cookies.delete(:user_id)
    @current_user = nil
  end
end
