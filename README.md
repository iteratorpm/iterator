<div align="center">
  <h1 align="center">Iterator</h1>
  <p align="center" class="text-xl">The <strong>developer-friendly</strong> project management tool for agile teams — inspired by the proven methodology of Pivotal Tracker.</p>
</div>

<div align="center">
  <a href="https://iteratorpm.com/changelog">Changelog</a>
  ·
  <a href="https://iteratorpm.com">Website</a>
  ·
  <a href="https://iteratorpm.com/docs">Docs</a>
  ·
  <a href="https://discord.gg/eHPZxVbP">Community</a>
</div>

<div align="center">
  <a href="https://github.com/iteratorpm/iterator/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/badge/license-AGPLv3-purple"></a>
  <a href="https://github.com/iteratorpm/iterator/stargazers"><img alt="Stars" src="https://img.shields.io/github/stars/iteratorpm/iterator?color=black"></a>
</div>

---

⚠️ **Early Alpha Warning**  
Iterator is currently in early alpha. Many features are incomplete or unstable, and the hosted version may break frequently.  
We're offering everything for free during the beta — and **feedback, bug reports, and contributions are very welcome**!

---

## 🚀 Key Features

### 📅 Planning & Workflow
- **Velocity Planning**  
  Manual and automatic iteration modes with intelligent tracking to predict delivery dates.
- **Story States & Labels**  
  Custom workflows, rich labeling, and keyboard shortcuts for fast team execution.
- **Workflow Flexibility**  
  Combine Kanban and Scrum with adaptable project structures.

### 📊 Analytics & Reporting _(Planned)_
- **Velocity & Cycle Time**  
  Visualize team throughput and identify bottlenecks.
- **Burnup & Cumulative Flow Charts**  
  Monitor scope creep and visualize work distribution.
- **Activity Feed**  
  Track every comment, status change, and assignment.

### 🔌 Developer Experience _(Planned)_
- **Version Control Integration**  
  GitHub and GitLab integration for commit linking and PR status updates.
- **API + Webhooks**  
  A powerful REST API and custom webhook support for toolchain integrations.
- **Real-time Activity Sync**  
  Unified notifications and event streams across connected tools.

---

## 💡 Why Iterator?

With Pivotal Tracker shutting down, we needed a replacement that kept its best ideas — automatic sprint planning, tight workflow, and release planning — but none of the outdated UX. Modern tools are bloated or are a kanban board that can't estimate when features will be completed.

**Iterator is built for developers** who want to spend less time managing and more time building. It's designed so that 99% of your time is spent on a single, focused screen — no jumping between tabs, views, or dashboards.

We're also rethinking the developer experience from the ground up, with features like keyboard-first navigation, AI integration, and Git workflows — all optimized for speed and flow.

## 🖼️ Screenshot

---

## 🛠️ Tech Stack

- **Ruby on Rails 8** (Hotwire Turbo + Stimulus)
- **SQLite/PostgreSQL** (your choice)
- **Tailwind CSS** for modern styling
- **Docker/Kamal** for easy deployment

---

## 🚀 Get Started in Minutes

### One-Line Docker Command
```bash
docker run -d \
  -p 3000:3000 \
  -e ADMIN=admin@example.com:password \
  -v ./iterator-db:/usr/src/app/storage \
  iteratorpm/iterator:latest
```

Visit `http://localhost:3000` with demo credentials:

- Email: `admin@example.com`
- Password: `password`

⚠️  This runs in demo mode with no email verification.

### Docker Compose

```bash
git clone https://github.com/iteratorpm/iterator
cd iterator
cp .env.example .env
docker compose up -d
```

### Kamal (Production Deployment) (Planned)
```bash
kamal init
kamal env push
kamal a
kamal deploy
```

📘 [Full deployment guide](https://iteratorpm.com/docs/guides/installation/)

---

## 💬 Join Our Community

[![Discord](https://img.shields.io/badge/chat-Discord-7289DA)](https://discord.gg/eHPZxVbP)
[![GitHub Issues](https://img.shields.io/github/issues/iteratorpm/iterator)](https://github.com/iteratorpm/iterator/issues)

We welcome contributions! Check out our [contribution guidelines](CONTRIBUTING.md).

---

## 📜 License

Iterator is [AGPLv3 licensed](LICENSE).
