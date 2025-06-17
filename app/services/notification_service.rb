class NotificationService
  def self.notify(user, notification_type, notifiable, delivery_method = :both)
    return if user == notifiable.try(:user) # Don't notify yourself

    project = notifiable.try(:project)

    # Check if project is muted
    if project && muted?(user, project)
      return if notification_type != :mention_in_comment ||
               (!muted_except_mentions?(user, project) && notification_type == :mention_in_comment)
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
    actor_name = extract_actor_name(notifiable)

    case notification_type.to_sym
    when :story_created
      "#{actor_name} created a new story"
    when :story_delivered
      "#{actor_name} delivered story for review"
    when :story_accepted
      "#{actor_name} accepted your story"
    when :story_rejected
      "#{actor_name} rejected your story with feedback"
    when :story_assigned
      "#{actor_name} assigned you to this story"
    when :comment_created
      "#{actor_name} commented on this story"
    when :mention_in_comment
      "#{actor_name} mentioned you in a comment"
    when :blocker_added
      "#{actor_name} added a blocker to this story"
    when :blocker_resolved
      "#{actor_name} resolved a blocker on this story"
    when :story_blocking
      "This story is blocking other work and needs attention"
    when :comment_reaction
      "#{actor_name} reacted to your comment"
    when :review_assigned
      "#{actor_name} assigned you as a reviewer"
    when :review_delivered
      "A story you're reviewing has been delivered by #{actor_name}"
    else
      "You have a new notification"
    end
  end

  def self.send_notification_email(notification)
    NotificationMailer.with(notification: notification).notification_email.deliver_later
  end

  private

  def self.extract_actor_name(notifiable)
    # Try to extract the actor from different possible associations
    actor = case notifiable
            when Comment
              notifiable.author
            when Story
              notifiable.requester || notifiable.owner
            when Blocker
              notifiable.creator
            when Review
              notifiable.reviewer
            when User
              notifiable
            else
              nil
            end

    actor&.name || "Someone"
  end

end
