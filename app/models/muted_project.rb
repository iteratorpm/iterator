class MutedProject < ApplicationRecord
  belongs_to :user
  belongs_to :project

  enum :mute_type, { all_notifications: 0, except_mentions: 1 }
end
