class WhatsNewController < ApplicationController
  def whats_new
    @updates = [
      {
        version: "v0.0.1",
        date: "2025-06-04",
        changes: [
          "🔥 Now officially in early alpha, be aware of bugs"
        ]
      }
    ]
  end
end
