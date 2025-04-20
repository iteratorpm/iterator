import consumer from "./consumer"

consumer.subscriptions.create(
  { channel: "ProjectChannel", project_id: PROJECT_ID }, 
  {
    received(data) {
      if (data.action === "story_recovered") {
        if (confirm("A story was recovered. Reload the page to see updates?")) {
          window.location.reload()
        }
      }
    }
  }
)
