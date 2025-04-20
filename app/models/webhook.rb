class Webhook < ApplicationRecord
  belongs_to :project

  validates :webhook_url, presence: true, url: true

  def toggle_enabled!
    update(enabled: !enabled)
  end
end
