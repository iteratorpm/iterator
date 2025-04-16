class NotificationMailer < ApplicationMailer
  def notification_email
    @notification = params[:notification]
    @user = @notification.user
    @project = @notification.project
    @notifiable = @notification.notifiable

    subject = if @user.notification_settings.find_by(project: nil).email_titles_enabled?
                "[#{@project.name}] #{@notification.message}"
              else
                "[#{@project.name}] Notification"
              end

    mail(to: @user.email, subject: subject)
  end
end
