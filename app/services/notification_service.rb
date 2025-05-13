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
    send_notification_email(notification) if actual_delivery == :email || actual_delivery == :both

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
    return nil unless setting.in_app_state_enabled? || setting.email_state_enabled?

    if requested_method == :both
      if setting.in_app_state_enabled? && setting.email_state_enabled?
        :both
      elsif setting.in_app_state_enabled?
        :in_app
      elsif setting.email_state_enabled?
        :email
      else
        nil
      end
    elsif requested_method == :in_app
      setting.in_app_state_enabled? ? :in_app : nil
    else # :email
      setting.email_state_enabled? ? :email : nil
    end
  end

  def self.generate_message(notification_type, notifiable)
    case notification_type.to_sym
    when :story_created
      "New story '#{notifiable.name}' was created"

    when :story_delivered
      "Story '#{notifiable.name}' was delivered"

    when :story_accepted
      "Story '#{notifiable.name}' was accepted"

    when :story_rejected
      "Story '#{notifiable.name}' was rejected"

    when :story_assigned
      "You were assigned to story '#{notifiable.name}'"

    when :comment_created
      "New comment on story '#{notifiable.story.name}'"

    when :mention_in_comment
      "You were mentioned in a comment on '#{notifiable.commentable.name}'"

    when :blocker_added
      "Blocker added to story '#{notifiable.story.name}'"

    when :blocker_resolved
      "Blocker resolved on story '#{notifiable.story.name}'"

    when :story_blocking
      "Story '#{notifiable.name}' is blocking another story"

    when :comment_reaction
      "Someone reacted to your comment on story '#{notifiable.story.name}'"

    when :review_assigned
      "You were assigned as a reviewer on story '#{notifiable.story.name}'"

    when :review_delivered
      "Story '#{notifiable.story.name}' you are reviewing has been delivered"

    else
      "You have a new notification"
    end
  end

  def self.send_notification_email(notification)
    NotificationMailer.with(notification: notification).notification_email.deliver_later
  end
end
