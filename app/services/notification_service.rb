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
    setting = user.find_or_create_notification_setting

    # Determine which delivery methods should be used
    delivery_methods = calculate_delivery_methods(setting, notification_type, delivery_method, user, notifiable)
    return if delivery_methods.empty?

    notifications = []

    # Create notifications for each delivery method
    delivery_methods.each do |method|
      notification = user.notifications.create(
        notification_type: notification_type,
        notifiable: notifiable,
        project: project,
        delivery_method: method,
        message: generate_message(notification_type, notifiable)
      )

      if notification.persisted?
        notifications << notification

        # Send email if this is an email notification
        send_notification_email(notification) if method == :email
      end
    end

    # Return single notification if only one was created, otherwise return array
    notifications.length == 1 ? notifications.first : notifications
  end

  private

  def self.muted?(user, project)
    user.muted_projects.where(project: project).exists?
  end

  def self.muted_except_mentions?(user, project)
    user.muted_projects.where(project: project, mute_type: :except_mentions).exists?
  end

  def self.calculate_delivery_methods(setting, notification_type, requested_method, user, notifiable)
    methods = []

    # Check if in-app notification should be sent
    if should_send_in_app?(setting, notification_type, requested_method, user, notifiable)
      methods << :in_app
    end

    # Check if email notification should be sent
    if should_send_email?(setting, notification_type, requested_method, user, notifiable)
      methods << :email
    end

    methods
  end

  def self.should_send_in_app?(setting, notification_type, requested_method, user, notifiable)
    return false unless setting.in_app_state_enabled?
    return false if requested_method == :email

    should_notify_in_app?(setting, notification_type, user, notifiable)
  end

  def self.should_send_email?(setting, notification_type, requested_method, user, notifiable)
    return false unless setting.email_state_enabled?
    return false if requested_method == :in_app

    should_notify_email?(setting, notification_type, user, notifiable)
  end

  def self.should_notify_in_app?(setting, notification_type, user, notifiable)
    case notification_type
    when :story_created
      setting.in_app_story_creation_yes?
    when :story_delivered, :story_accepted, :story_rejected
      setting.in_app_story_state_all? ||
      (setting.in_app_story_state_relevant? && is_story_state_relevant_to_user?(notification_type, user, notifiable))
    when :comment_created
      setting.in_app_comments_all?
    when :mention_in_comment
      setting.in_app_comments_mentions_only? || setting.in_app_comments_all?
    when :blocker_added, :blocker_resolved, :story_blocking
      setting.in_app_blockers_all? || setting.in_app_blockers_followed_stories?
    when :comment_reaction
      setting.in_app_comment_reactions_yes?
    when :review_assigned, :review_delivered
      setting.in_app_reviews_yes?
    else
      true
    end
  end

  def self.should_notify_email?(setting, notification_type, user, notifiable)
    case notification_type
    when :story_created
      setting.email_story_creation_yes?
    when :story_delivered, :story_accepted, :story_rejected
      setting.email_story_state_all? ||
      (setting.email_story_state_relevant? && is_story_state_relevant_to_user?(notification_type, user, notifiable))
    when :comment_created
      setting.email_comments_all?
    when :mention_in_comment
      setting.email_comments_mentions_only? || setting.email_comments_all?
    when :blocker_added, :blocker_resolved, :story_blocking
      setting.email_blockers_all? || setting.email_blockers_followed_stories?
    when :comment_reaction
      setting.email_comment_reactions_yes?
    when :review_assigned, :review_delivered
      setting.email_reviews_yes?
    else
      true
    end
  end

  def self.is_story_state_relevant_to_user?(notification_type, user, story)
    case notification_type
    when :story_delivered
      # Relevant if user is the requester
      story.requester == user
    when :story_accepted, :story_rejected
      # Relevant if user is an owner of the story
      story.owners.include?(user)
    else
      false
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
      "New comment on story '#{notifiable.commentable.name}'"

    when :mention_in_comment
      "You were mentioned in a comment on '#{notifiable.commentable.name}'"

    when :blocker_added
      "Blocker added to story '#{notifiable.story.name}'"

    when :blocker_resolved
      "Blocker resolved on story '#{notifiable.story.name}'"

    when :story_blocking
      "Story '#{notifiable.name}' is blocking another story"

    when :comment_reaction
      "Someone reacted to your comment on story '#{notifiable.commentable.name}'"

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
