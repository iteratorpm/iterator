class UserInvitationMailer < ApplicationMailer
  def invitation_email(user)
    @user = user
    @invitation_url = confirm_invitation_url(token: @user.confirmation_token)
    mail(to: @user.email, subject: "You've been invited to join")
  end

  private

  def confirm_invitation_url(token)
    Rails.application.routes.url_helpers.confirm_invitation_url(
      token: token,
      host: Rails.application.config.action_mailer.default_url_options[:host]
    )
  end
end
