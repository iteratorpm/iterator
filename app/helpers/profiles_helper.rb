module ProfilesHelper
  def user_avatar(owner, size: 6, data: {}, **options)
    options[:class] = Array(options[:class]).join(' ')
    options[:class] += " w-#{size} h-#{size} rounded-full"
    options[:data] = data

    render "projects/profile/avatar", user: owner, size: size, options: options
  end
end
