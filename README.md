# 🛠️ Iterator – Open Source Agile Project Management Tool

**Iterator** is an open-source, self-hostable project management tool inspired by [Pivotal Tracker](https://www.pivotaltracker.com). Built with Ruby on Rails, it brings agile software planning back to developers — free, fast, and fully transparent.

![screenshot](docs/screenshot.png)

---

## 🚀 Why Iterator?

Pivotal Tracker is a great tool, but it's closed-source and limited in customization. Iterator is:

- 🔓 **100% open source**
- 🏡 **Self-hostable**
- 💡 **Developer-first**
- 🔁 **Iteration-focused**

---

## ✨ Features

- 📁 Projects & teams
- 🧩 Stories (planned, started, finished, delivered, accepted, rejected)
- 🎯 Estimation (points-based)
- 🔄 Iteration scheduling (weekly/biweekly)
- 🧪 REST API (inspired by Tracker v5)
- 🔒 User authentication (Devise)
- ⚙️ Kamal-based deployment
- 🧪 Tests (RSpec) and seeds for local dev

---

## 📦 Tech Stack

- Ruby on Rails 8
- Hotwire (Turbo + Stimulus)
- Sqlite
- Kamal (for deployment)
- RSpec / FactoryBot

---

## 🚀 Deployment (via [Kamal](https://kamal-deploy.org))

You can deploy this app easily using [Kamal](https://kamal-deploy.org):

1. Configure your `.env` and `kamal.yml` (see `deploy/` folder)
2. Push with:
   ```bash
   kamal deploy
   ```
