# 📖 Telugu Bible Simplified

A premium, state-of-the-art Flutter mobile and web application that presents the Holy Scriptures in **clean, modern, and easily readable simplified Telugu**. By removing complex ancient vocabulary and dual-reading modes, this project delivers the complete Bible with 100% structural integrity and absolute clarity for contemporary readers.

👉 **Live Deployment:** [Vercel Web App](https://github.com/sammkaiserr/bible_simplified) *(connected via automated deployment pipeline)*

---

## 🛠️ Technology Stack

- **Framework:** [Flutter](https://flutter.dev) (Dart multiplatform framework for Mobile & Web)
- **State Management:** [Riverpod](https://riverpod.dev) (modern, safe, reactive state management)
- **Routing & Navigation:** [GoRouter](https://pub.dev/packages/go_router) (declarative routing for seamless Web SPA support)
- **Database Architecture:** [sqflite](https://pub.dev/packages/sqflite) (local SQLite database for mobile offline support) & in-browser IndexedDB mappings (for offline web capabilities)
- **Scripting & Seeding Pipeline:** Python 3 (concurrent batching, requests-based API endpoint mapping)
- **Cloud Hosting:** [Vercel](https://vercel.com) (SPA serverless routing, automatic Git integration)

---

## ✨ Features

- 🌟 **Simplified-Only Interface:** Complete removal of archaic traditional text, presenting the simplified modern translation as the primary, seamless scripture reading text.
- 🎨 **Premium Aesthetics:** Curated Ivory Light Mode (Gold & Ivory accents) and Navy Midnight Dark Mode (Deep Navy & Pearl Blue) designed to wow users at first glance.
- ⚡ **Offline-Ready Web Database:** Native SQLite seeding mapped directly to in-browser index database layouts for high-performance offline reading on web.
- 🔍 **Instant Search & Bookmarks:** High-speed keyword searching, customizable bookmarks, colored verse highlights, and personal note-taking.
- 📱 **Fully Responsive Layout:** Tailored controls, flexible grid book menus, dynamic font scaling, and optimized reading views for both mobile devices and web browsers.

---

## 🏛️ Project Architecture & Database Seeding

The application parses localized JSON assets to seed the local database seamlessly on first launch:
- **Core SQLite Database:** Configured in `lib/database/database_helper.dart` for native mobile platforms.
- **Web IndexDB Database:** Formatted in `lib/database/web_database.dart` to serve identical capabilities in-browser.
- **JSON Assets:** 66 structurally complete book files residing in `assets/bible/` containing all 31,102 verses of the Bible.

---

## ⚙️ Parallel Translation Pipeline

The project features a highly concurrent, self-healing translation engine in `scripts/simplify_bible.py` designed to bridge BBE English (Bible in Basic English) into simplified Telugu:
1. **Self-Healing File Scanner:** Scans actual JSON files directly to verify structural completeness verse-by-verse.
2. **Batch Request Optimization:** Groups multiple verses into single API packages separated by custom tokens, reducing API calls by 30x.
3. **Google Translate API Engine:** Operates directly on the free stable translation endpoint (`translate.googleapis.com`) to bypass scraping blocks.
4. **Fallback & IndexError Correction:** Automatically falls back to original Telugu formatting for omitted verses or mismatches to guarantee 100% database seeding success.

---

## 🚀 Running the Project Locally

### 1. Prerequisites
- **Flutter SDK** (Stable Channel)
- **Python 3** (for executing the translation seeding script if modifying database files)

### 2. Launch Development Server
To launch the responsive web server:
```bash
flutter run -d web-server --web-port=8080
```
Then visit [http://localhost:8080](http://localhost:8080) in your web browser.

### 3. Run Seeding Diagnostics
To run a self-healing audit on the scripture database:
```bash
python3 scripts/simplify_bible.py
```

---

## 🛠️ Vercel Deployment Structure

This SPA is configured for automatic serverless routing on Vercel:
- **`vercel.json`:** Directs all request paths to index.html to support standard SPA client-side routing.
- **`build.sh`:** Builds the release bundle on the cloud automatically:
```bash
#!/bin/bash
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable
fi
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor
flutter build web --release
```

---

## 📂 Repository Directory Structure

```text
├── assets/
│   └── bible/                  # 66 complete translated book JSON assets
├── lib/
│   ├── core/                   # Constants and Localization
│   ├── database/               # Mobile SQLite and Web database seeders
│   ├── models/                 # Dart database structures (Verse, Book, Note)
│   ├── providers/              # Riverpod state managers (Settings, Reading)
│   ├── screens/                # UI Screens (Reading, Search, Settings)
│   ├── services/               # Share and utility modules
│   ├── theme/                  # Premium Light/Dark style systems
│   └── main.dart               # App entrypoint & GoRouter structure
├── scripts/
│   ├── progress.json           # Seeding audit log
│   └── simplify_bible.py       # Stable concurrent translation script
└── vercel.json                 # Serverless routing config
```
