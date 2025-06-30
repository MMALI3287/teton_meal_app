# AGENT.md - Teton Meal App Development Guide

> *This guide helps automated agents understand project conventions, pipelines, and responsibilities to ensure consistent, quality contributions.*

---

## 🛠 Agent Setup & Initialization

* **Repository Clone & Dependencies**:

  ```bash
  git clone https://github.com/MMALI3287/teton_meal_app.git
  cd teton_meal_app
  flutter pub get
  ```

* **Credentials & Environment**:

  * Store Firebase service account keys in `functions/.env`.
  * Authenticate CI with `firebase login:ci` and set `FIREBASE_TOKEN`.

## 🤖 Agent Roles & Workflows

### 1. Lint & Format Agent

* **Trigger**: On any PR to `feature/*` or `main`.
* **Commands**:

  ```bash
  flutter analyze
  flutter format --set-exit-if-changed .
  ```

* **Outcome**: Report lint errors and formatting diffs as PR comments.

### 2. Test Runner Agent

* **Trigger**: On PR events and nightly builds.
* **Commands**:

  ```bash
  flutter test --coverage
  ```

* **Outcome**: Upload coverage report; retry failures up to 2×.

### 3. Build & Release Agent

* **Trigger**: On push to `main` or `release/*` branches.
* **Commands**:

  ```bash
  flutter build apk --release
  flutter build ios --release
  flutter build web --release
  ```

* **Outcome**: Publish artifacts to `artifacts/<branch>/<date>/`, tag release.

### 4. Dependency & Security Audit Agent

* **Trigger**: Weekly schedule.
* **Commands**:

  ```bash
  flutter pub outdated
  npm audit # for any Node-based scripts
  ```

* **Outcome**: Open PRs to bump critical or vulnerable dependencies.

## 📌 Interaction Patterns

* **Branch Naming**: `feature/<JIRA-ID>-short-desc` or `bugfix/<ID>-short-desc`.
* **Commit Messages**: Follow Conventional Commits:

* **PR Requirements**:
  * Linked issue/ticket
  * Summary of changes
  * Test coverage report (if applicable)
  * Screenshots or logs for UI/behavior changes

## 📐 Code Style & Conventions

* **Imports**: Flutter SDK → 3rd-party packages → local modules
* **Indentation**: 2 spaces; trailing commas in multi-line literals
* **Naming**: `camelCase` for methods/vars, `PascalCase` for classes/files, `snake_case` for tests
* **Error Handling**: Wrap async Firebase operations in `try/catch`; use `if (kDebugMode)` for debug logs
* **UI Styling**: All colors via `AppColors`; no hard-coded hex values
* **Responsive Layout**: Use `flutter_screenutil` units (`.w`, `.h`, `.sp`, `.r`)

## 📂 Project Structure Overview

```text
teton_meal_app/
├── lib/
│   ├── Screens/           # UI screens and navigation
│   ├── Styles/            # AppColors and styling constants
│   ├── services/          # Business logic and Firebase interactions
│   └── main.dart          # Application entry point
├── functions/             # Firebase Cloud Functions and environment
├── android/ ios/ web/     # Platform-specific directories
├── pubspec.yaml           # Dependency declarations
└── README.md              # User-facing documentation
```

## 📦 Artifacts & Outputs

* **Build Artifacts**: Save APKs/IPAs/Web bundles under `artifacts/<branch>/<yyyy-mm-dd>/`
* **Coverage Reports**: Store `coverage/lcov.info` and HTML reports for CI
* **Logs**: Persist agent logs in `logs/<agent>/<yyyy-mm-dd>.log`

## 🔧 Debugging & Diagnostics

* **Verbose Mode**: Run agents with `--verbose` or `--debug` flags
* **Local CI Simulation**: Use Docker:

  ```bash
  docker-compose -f ci/docker-compose.yml up --build
  ```

## 📚 References

* [Flutter Style Guide](https://flutter.dev/docs/development/ui/style)
* [Dart Language Tour](https://dart.dev/guides/language/language-tour)
* [Conventional Commits Spec](https://www.conventionalcommits.org/)

---

> *Empower your agents to keep Teton Meal App robust, reliable, and rock-solid!* 🚀
