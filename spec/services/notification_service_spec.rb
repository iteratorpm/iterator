require 'rails_helper'

RSpec.describe NotificationService, type: :service do
  let(:user) { create(:user) }
  let(:project) { create(:project) }
  let(:notifiable_user) { create(:user) }
  let(:story) { create(:story, project: project, requester: notifiable_user, name: "Important Story") }
  let(:comment) { create(:comment, commentable: story, author: notifiable_user) }

  let(:setting) do
    create(:notification_setting,
           user: user,
           in_app_story_creation: 'yes',
           email_story_creation: 'yes',
           in_app_comments: 'all',
           email_comments: 'mentions_only',
           in_app_state: 'enabled',
           email_state: 'enabled')
  end

  before do
    setting # ensure the setting is created
    allow(NotificationMailer).to receive_message_chain(:with, :notification_email, :deliver_later)
  end

  describe '.notify' do
    context 'when both in-app and email are enabled and allowed' do
      it 'creates both in-app and email notifications' do
        notifications = NotificationService.notify(user, :story_created, story)

        expect(notifications).to be_an(Array)
        expect(notifications.length).to eq(2)

        in_app_notification = notifications.find { |n| n.delivery_method == 'in_app' }
        email_notification = notifications.find { |n| n.delivery_method == 'email' }

        expect(in_app_notification).to be_present
        expect(email_notification).to be_present

        [in_app_notification, email_notification].each do |notification|
          expect(notification.notification_type).to eq("story_created")
          expect(notification.project).to eq(project)
          expect(notification.user).to eq(user)
          expect(notification.message).to include("New story")
        end
      end

      it 'sends email for email notification only' do
        NotificationService.notify(user, :story_created, story)

        expect(NotificationMailer).to have_received(:with).once
      end
    end

    context 'when only in-app is enabled' do
      before do
        setting.update!(email_state: 'disabled')
      end

      it 'creates only in-app notification' do
        notification = NotificationService.notify(user, :story_created, story)

        expect(notification).not_to be_an(Array)
        expect(notification.delivery_method).to eq('in_app')
        expect(notification.notification_type).to eq("story_created")
      end

      it 'does not send email' do
        NotificationService.notify(user, :story_created, story)

        expect(NotificationMailer).not_to have_received(:with)
      end
    end

    context 'when only email is enabled' do
      before do
        setting.update!(in_app_state: 'disabled')
      end

      it 'creates only email notification' do
        notification = NotificationService.notify(user, :story_created, story)

        expect(notification).not_to be_an(Array)
        expect(notification.delivery_method).to eq('email')
        expect(notification.notification_type).to eq("story_created")
      end

      it 'sends email' do
        NotificationService.notify(user, :story_created, story)

        expect(NotificationMailer).to have_received(:with).once
      end
    end

    context 'when delivery method is explicitly set to :in_app' do
      it 'creates only in-app notification' do
        notification = NotificationService.notify(user, :story_created, story, :in_app)

        expect(notification).not_to be_an(Array)
        expect(notification.delivery_method).to eq('in_app')
      end

      it 'does not send email' do
        NotificationService.notify(user, :story_created, story, :in_app)

        expect(NotificationMailer).not_to have_received(:with)
      end
    end

    context 'when delivery method is explicitly set to :email' do
      it 'creates only email notification' do
        notification = NotificationService.notify(user, :story_created, story, :email)

        expect(notification).not_to be_an(Array)
        expect(notification.delivery_method).to eq('email')
      end

      it 'sends email' do
        NotificationService.notify(user, :story_created, story, :email)

        expect(NotificationMailer).to have_received(:with).once
      end
    end

    context 'with different notification type preferences' do
      before do
        setting.update!(
          in_app_comments: 'mentions_only',
          email_comments: 'all'
        )
      end

      context 'for regular comment' do
        it 'creates only email notification' do
          notification = NotificationService.notify(user, :comment_created, comment)

          expect(notification).not_to be_an(Array)
          expect(notification.delivery_method).to eq('email')
        end
      end

      context 'for mention in comment' do
        it 'creates both notifications' do
          notifications = NotificationService.notify(user, :mention_in_comment, comment)

          expect(notifications).to be_an(Array)
          expect(notifications.length).to eq(2)

          delivery_methods = notifications.map(&:delivery_method)
          expect(delivery_methods).to contain_exactly('in_app', 'email')
        end
      end
    end

    context 'when user is the one who created the story' do
      it 'does not create any notifications' do
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
        notifications = NotificationService.notify(user, :mention_in_comment, comment)

        expect(notifications).to be_present
        if notifications.is_a?(Array)
          expect(notifications.first.notification_type).to eq("mention_in_comment")
        else
          expect(notifications.notification_type).to eq("mention_in_comment")
        end
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

      it 'does not create any notifications' do
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

    context 'when requested delivery is :email but email is disabled' do
      before do
        setting.update!(in_app_state: 'enabled', email_state: 'disabled')
      end

      it 'does not create notification' do
        notification = NotificationService.notify(user, :story_created, story, :email)
        expect(notification).to be_nil
      end
    end

    context 'with specific notification type settings' do
      before do
        setting.update!(
          in_app_story_creation: 'no',
          email_story_creation: 'yes',
          in_app_comment_reactions: 'yes',
          email_comment_reactions: 'no'
        )
      end

      it 'respects in-app story creation setting' do
        notification = NotificationService.notify(user, :story_created, story)

        expect(notification).not_to be_an(Array)
        expect(notification.delivery_method).to eq('email')
      end

      it 'respects email comment reactions setting' do
        reaction = create(:comment, commentable: story)
        notification = NotificationService.notify(user, :comment_reaction, reaction)

        expect(notification).not_to be_an(Array)
        expect(notification.delivery_method).to eq('in_app')
      end
    end

    context 'story state changes with relevant setting' do
      let(:requester) { create(:user) }
      let(:owner) { create(:user) }
      let(:other_user) { create(:user) }
      let(:story_with_relationships) do
        create(:story, project: project, requester: requester, name: "Relevant Story").tap do |story|
          story.story_owners.create!(user: owner)
        end
      end

      before do
        setting.update!(
          in_app_story_state_changes: 'relevant',
          email_story_state_changes: 'relevant'
        )
      end

      context 'when story is delivered' do
        it 'notifies the requester' do
          requester_setting = create(:notification_setting,
                                   user: requester,
                                   in_app_story_state_changes: 'relevant',
                                   email_story_state_changes: 'relevant',
                                   in_app_state: 'enabled',
                                   email_state: 'enabled')

          notifications = NotificationService.notify(requester, :story_delivered, story_with_relationships)

          expect(notifications).to be_an(Array)
          expect(notifications.length).to eq(2)
          expect(notifications.map(&:delivery_method)).to contain_exactly('in_app', 'email')
        end

        it 'does not notify story owners' do
          owner_setting = create(:notification_setting,
                               user: owner,
                               in_app_story_state_changes: 'relevant',
                               email_story_state_changes: 'relevant',
                               in_app_state: 'enabled',
                               email_state: 'enabled')

          notification = NotificationService.notify(owner, :story_delivered, story_with_relationships)

          expect(notification).to be_nil
        end

        it 'does not notify unrelated users' do
          other_setting = create(:notification_setting,
                               user: other_user,
                               in_app_story_state_changes: 'relevant',
                               email_story_state_changes: 'relevant',
                               in_app_state: 'enabled',
                               email_state: 'enabled')

          notification = NotificationService.notify(other_user, :story_delivered, story_with_relationships)

          expect(notification).to be_nil
        end
      end

      context 'when story is accepted' do
        it 'notifies story owners' do
          owner_setting = create(:notification_setting,
                               user: owner,
                               in_app_story_state_changes: 'relevant',
                               email_story_state_changes: 'relevant',
                               in_app_state: 'enabled',
                               email_state: 'enabled')

          notifications = NotificationService.notify(owner, :story_accepted, story_with_relationships)

          expect(notifications).to be_an(Array)
          expect(notifications.length).to eq(2)
          expect(notifications.map(&:delivery_method)).to contain_exactly('in_app', 'email')
        end

        it 'does not notify the requester' do
          requester_setting = create(:notification_setting,
                                   user: requester,
                                   in_app_story_state_changes: 'relevant',
                                   email_story_state_changes: 'relevant',
                                   in_app_state: 'enabled',
                                   email_state: 'enabled')

          notification = NotificationService.notify(requester, :story_accepted, story_with_relationships)

          expect(notification).to be_nil
        end
      end

      context 'when story is rejected' do
        it 'notifies story owners' do
          owner_setting = create(:notification_setting,
                               user: owner,
                               in_app_story_state_changes: 'relevant',
                               email_story_state_changes: 'relevant',
                               in_app_state: 'enabled',
                               email_state: 'enabled')

          notifications = NotificationService.notify(owner, :story_rejected, story_with_relationships)

          expect(notifications).to be_an(Array)
          expect(notifications.length).to eq(2)
          expect(notifications.map(&:delivery_method)).to contain_exactly('in_app', 'email')
        end

        it 'does not notify the requester' do
          requester_setting = create(:notification_setting,
                                   user: requester,
                                   in_app_story_state_changes: 'relevant',
                                   email_story_state_changes: 'relevant',
                                   in_app_state: 'enabled',
                                   email_state: 'enabled')

          notification = NotificationService.notify(requester, :story_rejected, story_with_relationships)

          expect(notification).to be_nil
        end
      end

      context 'with mixed delivery preferences' do
        it 'respects different delivery preferences for relevant notifications' do
          owner_setting = create(:notification_setting,
                               user: owner,
                               in_app_story_state_changes: 'relevant',
                               email_story_state_changes: 'none',
                               in_app_state: 'enabled',
                               email_state: 'enabled')

          notification = NotificationService.notify(owner, :story_accepted, story_with_relationships)

          expect(notification).not_to be_an(Array)
          expect(notification.delivery_method).to eq('in_app')
        end
      end

      context 'when user is both requester and owner' do
        let(:user_both_roles) { create(:user) }
        let(:story_both_roles) do
          create(:story, project: project, requester: user_both_roles, name: "Story with dual role").tap do |story|
            story.story_owners.create!(user: user_both_roles)
          end
        end

        before do
          create(:notification_setting,
                 user: user_both_roles,
                 in_app_story_state_changes: 'relevant',
                 email_story_state_changes: 'relevant',
                 in_app_state: 'enabled',
                 email_state: 'enabled')
        end

        it 'notifies for story_delivered (as requester)' do
          notifications = NotificationService.notify(user_both_roles, :story_delivered, story_both_roles)

          expect(notifications).to be_an(Array)
          expect(notifications.length).to eq(2)
        end

        it 'notifies for story_accepted (as owner)' do
          notifications = NotificationService.notify(user_both_roles, :story_accepted, story_both_roles)

          expect(notifications).to be_an(Array)
          expect(notifications.length).to eq(2)
        end

        it 'notifies for story_rejected (as owner)' do
          notifications = NotificationService.notify(user_both_roles, :story_rejected, story_both_roles)

          expect(notifications).to be_an(Array)
          expect(notifications.length).to eq(2)
        end
      end

      context 'when user has "all" setting' do
        before do
          setting.update!(
            in_app_story_state_changes: 'all',
            email_story_state_changes: 'all'
          )
        end

        it 'notifies regardless of relationship to story' do
          notifications = NotificationService.notify(user, :story_delivered, story_with_relationships)

          expect(notifications).to be_an(Array)
          expect(notifications.length).to eq(2)
        end
      end
    end

    describe 'message generation' do
      it 'generates correct messages for different notification types' do
        test_cases = [
          [:story_created, story, "New story '#{story.name}' was created"],
          [:story_delivered, story, "Story '#{story.name}' was delivered"],
          [:story_accepted, story, "Story '#{story.name}' was accepted"],
          [:story_rejected, story, "Story '#{story.name}' was rejected"],
          [:comment_created, comment, "New comment on story '#{comment.commentable.name}'"],
          [:mention_in_comment, comment, "You were mentioned in a comment on '#{comment.commentable.name}'"]
        ]

        test_cases.each do |notification_type, notifiable, expected_message|
          notification = NotificationService.notify(user, notification_type, notifiable, :in_app)
          if notification.is_a?(Array)
            expect(notification.first.message).to eq(expected_message)
          else
            expect(notification.message).to eq(expected_message)
          end
        end
      end
    end
  end
end
