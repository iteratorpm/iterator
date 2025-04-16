class NotificationService
  def self.notify(user, notification_type, notifiable, delivery_method = :both)
    return if user == notifiable.try(:user) # Don't notify yourself

    project = notifiable.try(:project)

    # Check if project is muted
    if project && muted?(user, project)
      return if notification_type != :mention_in_comment ||
               (muted_except_mentions?(user, project) && notification_type == :mention_in_comment)
    end

    # Check user's notification settings
    setting = user.notification_settings.find_or_initialize_by(project: project)

    # Determine if notification should be sent based on settings
    return unless should_notify?(setting, notification_type)

    # Determine actual delivery method based on user preferences
    actual_delivery = calculate_delivery_method(setting, delivery_method)
    return if actual_delivery.nil?

    # Create the notification
    notification = user.notifications.create(
      notification_type: notification_type,
      notifiable: notifiable,
      project: project,
      delivery_method: actual_delivery,
      message: generate_message(notification_type, notifiable)
    )

    # Send email if needed
    send_notification_email(notification) if actual_delivery == 'email' || actual_delivery == 'both'

    notification
  end

  private

  def self.muted?(user, project)
    user.muted_projects.where(project: project).exists?
  end

  def self.muted_except_mentions?(user, project)
    user.muted_projects.where(project: project, mute_type: :except_mentions).exists?
  end

  def self.should_notify?(setting, notification_type)
    case notification_type
    when :story_created
      setting.story_creation_yes?
    when :story_delivered, :story_accepted, :story_rejected
      setting.story_state_all? ||
      (setting.story_state_relevant? && [:story_delivered, :story_accepted, :story_rejected].include?(notification_type))
    when :comment_created
      setting.comments_all?
    when :mention_in_comment
      true # Always notify for mentions
    when :blocker_added, :blocker_resolved, :story_blocking
      setting.blockers_all? || setting.blockers_followed_stories?
    when :comment_reaction
      setting.comment_reactions_yes?
    when :review_assigned, :review_delivered
      setting.reviews_yes?
    else
      true
    end
  end

  def self.calculate_delivery_method(setting, requested_method)
    return nil unless setting.in_app_status_enabled? || setting.email_status_enabled?

    if requested_method == :both
      if setting.in_app_status_enabled? && setting.email_status_enabled?
        :both
      elsif setting.in_app_status_enabled?
        :in_app
      elsif setting.email_status_enabled?
        :email
      else
        nil
      end
    elsif requested_method == :in_app
      setting.in_app_status_enabled? ? :in_app : nil
    else # :email
      setting.email_status_enabled? ? :email : nil
    end
  end

  def self.generate_message(notification_type, notifiable)
    # Implement message generation based on notification type and notifiable object
    # Example:
    case notification_type
    when :story_created
      "New story '#{notifiable.title}' was created"
    when :mention_in_comment
      "You were mentioned in a comment on '#{notifiable.story.title}'"
    # ... other cases
    end
  end

  def self.send_notification_email(notification)
    NotificationMailer.with(notification: notification).notification_email.deliver_later
  end
end
