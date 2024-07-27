module NavigationHelper
  def profile_path = user_path(current_user)
end
