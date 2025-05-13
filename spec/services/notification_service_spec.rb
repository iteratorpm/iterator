require 'rails_helper'

RSpec.describe NotificationService, type: :service do
  let(:user) { create(:user) }
  let(:project) { create(:project) }
  let(:notifiable_user) { create(:user) }
  let(:story) { create(:story, project: project, requester: notifiable_user, name: "Important Story") }
  let(:setting) { create(:notification_setting, user: user, project: project, story_creation: 'yes', in_app_state: 'enabled', email_state: 'enabled') }

  before do
    setting # ensure the setting is created
  end

  describe '.notify' do
    context 'when notifying user about a story creation' do
      it 'creates a notification' do
        notification = NotificationService.notify(user, :story_created, story)

        expect(notification).to be_persisted
        expect(notification.notification_type).to eq("story_created")
        expect(notification.project).to eq(project)
        expect(notification.user).to eq(user)
        expect(notification.message).to include("New story")
      end
    end

    context 'when user is the one who created the story' do
      it 'does not create a notification' do
        notification = NotificationService.notify(notifiable_user, :story_created, story)

        expect(notification).to be_nil
      end
    end

    context 'when project is muted for user' do
      before do
        user.muted_projects.create!(project: project, mute_type: :all_notifications)
      end

      it 'does not notify for non-mention' do
        notification = NotificationService.notify(user, :story_created, story)

        expect(notification).to be_nil
      end
    end

    context 'when project is muted except mentions' do
      before do
        user.muted_projects.create!(project: project, mute_type: :except_mentions)
      end

      it 'notifies if notification type is mention_in_comment' do
        comment = create(:comment, commentable: story, author: notifiable_user)
        notification = NotificationService.notify(user, :mention_in_comment, comment)

        expect(notification).to be_present
        expect(notification.notification_type).to eq("mention_in_comment")
      end

      it 'does not notify for other types' do
        notification = NotificationService.notify(user, :story_created, story)

        expect(notification).to be_nil
      end
    end

    context 'when user has disabled both in_app and email' do
      before do
        setting.update!(in_app_state: 'disabled', email_state: 'disabled')
      end

      it 'does not create a notification' do
        notification = NotificationService.notify(user, :story_created, story)

        expect(notification).to be_nil
      end
    end

    context 'when requested delivery is :in_app but in_app is disabled' do
      before do
        setting.update!(in_app_state: 'disabled', email_state: 'enabled')
      end

      it 'does not create notification' do
        notification = NotificationService.notify(user, :story_created, story, :in_app)

        expect(notification).to be_nil
      end
    end

    context 'when delivery method includes email' do
      it 'calls NotificationMailer' do
        allow(NotificationMailer).to receive_message_chain(:with, :notification_email, :deliver_later)

        NotificationService.notify(user, :story_created, story, :both)

        expect(NotificationMailer).to have_received(:with).with(notification: kind_of(Notification))
      end
    end
  end
end
