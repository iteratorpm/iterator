class WhatsNewController < ApplicationController
  def whats_new
    @updates = [
      {
        version: "v0.0.3",
        date: "2025-05-27",
        changes: [
          "🔥 New keyboard shortcuts panel",
          "🌈 Customizable workspace colors",
          "📊 Enhanced burndown charts"
        ],
        image: "../public/images/changelog/feature3.jpg"
      },
      {
        version: "v0.0.2",
        date: "2025-05-15",
        changes: [
          "📱 Improved mobile experience",
          "🚀 2x faster search performance",
          "🧩 New integrations marketplace"
        ],
        image: "../public/images/changelog/feature2.jpg"
      },
      {
        version: "v0.0.1",
        date: "2025-05-01",
        changes: [
          "✨ New epic roadmap view",
          "🛠 Improved performance for backlog filtering",
          "🧹 Cleaner sprint overview UI"
        ],
        image: "../public/images/changelog/feature1.jpg"
      }
    ]
  end
end
