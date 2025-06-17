class WhatsNewController < ApplicationController
  def whats_new
    @updates = [
      {
        version: "v0.0.1",
        date: "2025-06-04",
        changes: [
          "🔥 Now officially in beta, be aware of bugs"
        ]
      }
    ]
  end
end
