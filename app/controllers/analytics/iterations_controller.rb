class Analytics::IterationsController < ApplicationController
  def show
    @current_iteration = {
      name: "Apr 21 – May 4 (current)",
      options: [
        { value: 3, text: "Apr 21 – May 4 (current)" },
        { value: 2, text: "Apr 14 – Apr 20 (#2)" },
        { value: 1, text: "Apr 7 – Apr 13 (#1)" }
      ],
      points_accepted: 0,
      stories_accepted: 0,
      cycle_time: "--",
      rejection_rate: 0,
      burnup_data: {
        dates: (Date.today..Date.today + 13.days).to_a,
        scope: Array.new(14, 0),
        accepted: Array.new(14, 0),
        expected: (0..13).map { |i| (13 - i).to_f }
      },
      releases: [
        { name: "Launch Chrome/Firefox extension", scheduled: "Apr 11, 2025", completion: "May 4, 2025" },
        { name: "my reeleasez", scheduled: "Apr 12, 2025", completion: "May 25, 2025" }
      ],
      labels: [
        { name: "my label", points: 1, color: "#0A7640" }
      ],
      delivered_stories: [
        { id: 189053786, title: "next bug", points: 3, owner: "BE" }
      ],
      finished_stories: [
        { id: 189053785, title: "next", points: 2, owner: "BE" }
      ],
      started_stories: [
        { id: 189053783, title: "working", points: 1, owner: "BE", labels: ["my label"] }
      ]
    }
  end
end
