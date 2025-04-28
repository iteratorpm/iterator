# 🚀 Iterator – Open-Source Agile Tracker for Developers

**Iterator** is a self-hosted alternative to Pivotal Tracker built by developers, for developers. Get **lightweight agile planning** without SaaS lock-in or enterprise bloat.

![screenshot](docs/screenshot.png)

---

## 🔥 Why Developers Choose Iterator

### ⚡ **Git-Native Workflow**
- Auto-sync stories with **GitHub/GitLab issues/PRs**
- CLI tools for terminal lovers
- REST API for custom integrations

### 🧠 **Smart Agile Features**
- AI-assisted backlog grooming *(beta)*
- Velocity tracking with burn-down charts
- Keyboard-first navigation (Vim-style shortcuts)

### 🛠️ **Painless Self-Hosting**
- Deploy in 5 mins with Docker/Kamal
- Sqlite support (no PostgreSQL required for small teams)
- Minimal infrastructure footprint

---

## ✨ Core Features

| Developer Essentials | Agile Power-Ups |
|----------------------|-----------------|
| ✅ GitHub/GitLab sync | ✅ Auto-sprint planning |
| ✅ CLI + REST API | ✅ Velocity tracking |
| ✅ Kamal deployment | ✅ Icebox prioritization |
| ✅ Keyboard shortcuts | ✅ Iteration reports |

---

## 🛠️ Tech Stack

- **Ruby on Rails 8** (Hotwire Turbo + Stimulus)
- **Sqlite/Postgres/MySql** (your choice)
- **Kamal** (zero-downtime deploys)
- **RSpec** (100% test coverage goal)

---

## 🚀 Self-Hosting Guide

### 1. Docker Quickstart
```bash
git clone https://github.com/your-repo/iterator
cd iterator
cp .env.example .env  # Configure your secrets
docker compose up -d  # That's it!
```

### 2. Kamal for Production
```bash
# Set up Kamal (1-time)
kamal env push
kamal accessory boot

# Deploy!
kamal deploy
```

📘 Full docs: [SELF_HOSTING.md](docs/SELF_HOSTING.md)

---

## 💡 Why We Built This

After struggling with:
- Jira's complexity
- Pivotal Tracker's shutdown
- GitHub Projects' lack of agile features

...we made **Iterator** to give teams:
- **Control** (self-host anywhere)
- **Transparency** (100% open-source)
- **Developer joy** (no more PM tool frustration)

---

## 👥 Join the Community
[![Discord](https://img.shields.io/badge/chat-Discord-7289DA)](your-invite-link)
[![GitHub Issues](https://img.shields.io/github/issues/your-repo/iterator)](https://github.com/bendangelo/iterator/issues)

**Contribute:** We welcome PRs! See [CONTRIBUTING.md](CONTRIBUTING.md)
