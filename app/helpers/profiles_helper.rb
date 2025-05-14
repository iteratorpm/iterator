module ProfilesHelper
  def user_avatar user, size: 6
    render "projects/profile/avatar", user: user, size: size
  end

end
