# Orbit

<center>

![Orbit](dock_screenshot.png)

**The AI-Augmented Browser Workspace for macOS**

[![Swift 5.10](https://img.shields.io/badge/Swift-5.10-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-macOS%2014%2B-lightgrey.svg)](https://www.apple.com/macos/)
[![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](LICENSE)
[![Build](https://github.com/chindris-mihai-alexandru/Orbit/actions/workflows/swift-build.yml/badge.svg)](https://github.com/chindris-mihai-alexandru/Orbit/actions/workflows/swift-build.yml)
[![codecov](https://codecov.io/gh/chindris-mihai-alexandru/Orbit/graph/badge.svg)](https://codecov.io/gh/chindris-mihai-alexandru/Orbit)
[![Version](https://img.shields.io/badge/version-0.0.0-blue.svg)](https://github.com/chindris-mihai-alexandru/Orbit/releases)

</center>

---

## What is Orbit?

**Orbit** is a macOS-native browser workspace that goes beyond Safari's "Add to Dock" by providing:

- **Local AI Sidecar**: Chat with your web apps using local LLMs (Ollama, LM Studio)
- **Per-App Networking**: Route individual apps through specific proxies or VPNs
- **Deep Customization**: Persistent CSS/JS injection to fix and enhance web apps

Unlike Safari PWAs (which are "dumb windows") or Electron apps (which are bloated), Orbit gives power users the tools they need to **augment** their web app experience.

---

## Why Orbit?

| Feature | Safari PWA | Electron | Orbit |
|---------|------------|----------|-------|
| Memory Usage | 200-300MB | 300-500MB | <100MB |
| Local AI Integration | No | DIY | Built-in |
| Per-App Proxy | No | DIY | Built-in |
| Persistent Mods | No | DIY | Built-in |
| macOS Native | Yes | No | Yes |
| Open Source | No | Varies | GPL-3.0 |

---

## Core Features

### 1. Local AI Sidecar

Connect to Ollama or any OpenAI-compatible API running locally. Orbit can read page context and help you:

- Summarize long documents
- Draft replies to emails
- Analyze GitHub PRs and Jira tickets
- Explain error messages

**Your data never leaves your Mac.**

### 2. Network Tunneling

Route specific apps through different network configurations:

- Test from different geo-locations
- Debug with Charles/Proxyman per-app
- Keep work apps on VPN while personal apps are direct

### 3. God Mode Injection

Permanently fix annoying UIs:

- Dark mode for sites that don't support it
- Remove distractions (YouTube shorts, Gmail promotions)
- Add missing features to enterprise apps

Scripts sync across your Macs via iCloud.

---

## Installation

### Build from Source

```bash
git clone https://github.com/chindris-mihai-alexandru/Orbit.git
cd Orbit
swift build --configuration release
```

### Homebrew (Coming Soon)

```bash
brew install orbit-browser
```

---

## Quick Start

### Create a Web App

```bash
orbit create https://gmail.com --name Gmail
orbit create https://github.com --name GitHub --icon ~/icons/github.png
```

### Enable AI Sidecar

1. Install [Ollama](https://ollama.ai) and run a model: `ollama run llama3`
2. Open Orbit Settings > AI > Enable Sidecar
3. Press `Cmd+Shift+A` in any app to open the AI panel

### Inject Custom CSS

```bash
orbit inject Gmail --css ~/styles/gmail-dark.css
```

---

## Project Status

**Current Phase: Modernization & Pivot**

- [x] Swift 5.10 + macOS 14 support
- [x] WebKit API modernization
- [x] CI/CD infrastructure (CodeQL, Swift Build)
- [ ] AI Sidecar implementation
- [ ] Network tunneling features
- [ ] Script injection system

**Target v1.0**: Q3 2026

See [PIVOT_STRATEGY.md](PIVOT_STRATEGY.md) for the full roadmap.

---

## Documentation

- [Pivot Strategy](PIVOT_STRATEGY.md) - Why Orbit, technical vision
- [Getting Started](docs/getting-started.md)
- [AI Configuration](docs/ai-config.md)
- [Network Setup](docs/network.md)
- [Scripting Guide](docs/scripting.md)
- [Contributing](CONTRIBUTING.md)

---

## Architecture

```
+------------------------------------------+
|              Orbit Window                |
+------------------------------------------+
|  +----------------+  +----------------+  |
|  |                |  |                |  |
|  |    WebView     |  |   AI Sidebar   |  |
|  |  (WKWebView)   |  |   (SwiftUI)    |  |
|  |                |  |                |  |
|  +----------------+  +----------------+  |
+------------------------------------------+
         |                    |
         v                    v
+------------------+  +------------------+
| Page Context     |  | LLM Client       |
| Extractor        |  | (Ollama/OpenAI)  |
+------------------+  +------------------+
```

---

## Contributing

Orbit is community-driven! We especially welcome:

- Swift developers familiar with WebKit
- UX designers for the AI interface
- Testers with specific web app needs

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/ai-sidecar`)
3. Commit changes (`git commit -m 'Add AI sidecar'`)
4. Push (`git push origin feature/ai-sidecar`)
5. Open a Pull Request

---

## Related Projects

- **[PakePlus](../PakePlus)**: Our Tauri-based cross-platform web app wrapper (use for distribution)
- **[MacPin](https://github.com/kfix/MacPin)**: The original project Orbit is forked from

---

## License

Orbit is licensed under the GNU General Public License v3.0.

This project is a modernization and pivot of [MacPin](https://github.com/kfix/MacPin) by kfix, originally licensed under GPL-3.0.

---

## Acknowledgments

- **kfix** - Original MacPin creator
- **Apple WebKit Team** - Modern PWA APIs
- **Ollama** - Local LLM infrastructure
- **hongbomiao.com** - Inspiration for project organization

---

## Contact

- **GitHub Issues**: [Report bugs](https://github.com/chindris-mihai-alexandru/Orbit/issues)
- **Security**: chindris.mihai.alexandru@gmail.com

---

<center>

**Built with Swift, WebKit, and Local AI**

[Star us on GitHub](https://github.com/chindris-mihai-alexandru/Orbit) | [Read the Strategy](PIVOT_STRATEGY.md)

</center>
