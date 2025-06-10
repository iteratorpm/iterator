<div align="center">
  <h1 align="center">Iterator</h1>
  <p align="center" class="text-xl">The <strong>developer-friendly</strong> project management tool for agile teams. Based on the proven methodology of Pivotal Tracker.</p>
</div>

<div align="center">
  <a href="https://iteratorpm.com/changelog">Changelog</a>
  ·
  <a href="https://iteratorpm.com">Website</a>
  ·
  <a href="https://iteratorpm.com/docs">Docs</a>
  ·
  <a href="https://discord.gg/">Community</a>
</div>

<div align="center">
  <a href="https://github.com/iteratorpm/iterator/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/badge/license-AGPLv3-purple"></a>
  <a href="https://github.com/iteratorpm/iterator/stargazers"><img alt="Stars" src="https://img.shields.io/github/stars/iteratorpm/iterator?color=black"></a>
</div>

## 🚀 Key Features

### 📅 Planning & Workflow
- **Velocity Planning**: Automatic/manual iteration modes with intelligent tracking
- **Story States & Labels**: Customizable workflows with keyboard shortcuts
- **Methodology Flexibility**: Combine Kanban and Scrum approaches

### 📊 Powerful Analytics (Planned)
- **Velocity & Cycle Time**: Track team performance over time
- **Burnup Charts**: Monitor scope creep and progress
- **Cumulative Flow**: Visualize work distribution and bottlenecks

### 🔌 Developer Experience (Planned)
- **GitHub/GitLab Integration**: Automatic commit linking and PR status
- **REST API + Webhooks**: Connect with your existing toolchain
- **Real-time Activity Sync**: Unified feeds across all tools

## 🖼️ Screenshot

---

## 🛠️ Tech Stack

- **Ruby on Rails 8** (Hotwire Turbo + Stimulus)
- **SQLite/PostgreSQL** (your choice)
- **Tailwind CSS** for modern styling
- **Docker** for easy deployment

---

## 🚀 Get Started in Minutes

### One-Line Docker Demo (Quick Test)
```bash
docker run -p 3000:3000 iteratorpm/iterator
```
Visit `http://localhost:3000` with demo credentials:
- Email: `demo@example.com`
- Password: `password`

⚠️  This runs in demo mode with in-memory SQLite and no email verification.

### Docker Compose (Persistent Setup)
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

📘 [Full deployment guide](https://iteratorpm.com/docs/installation)

---

## 💬 Join Our Community

[![Discord](https://img.shields.io/badge/chat-Discord-7289DA)](https://discord.gg/)
[![GitHub Issues](https://img.shields.io/github/issues/iteratorpm/iterator)](https://github.com/iteratorpm/iterator/issues)

We welcome contributions! Check out our [contribution guidelines](CONTRIBUTING.md).

---

## 📜 License

Iterator is [AGPLv3 licensed](LICENSE).
