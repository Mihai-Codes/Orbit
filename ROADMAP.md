# Orbit Development Roadmap

## Project Vision

**Orbit** is the AI-augmented browser workspace for macOS power users. Unlike Safari's basic "Add to Dock" PWAs, Orbit provides **local AI integration**, per-app network isolation, and deep web app customization.

**Tagline**: "Your intelligent web workspace."

---

## Current Status (January 5, 2026)

### Version: 0.2.0

### ✅ Build Status: SUCCESS
- **Swift**: 5.10+ (6.0 compatible)
- **macOS**: 14.0+ (Sonoma)
- **Architecture**: arm64 (Apple Silicon)
- **Tests**: 27 unit tests passing

### ✅ Completed This Release
- Rebrand from PWA-Kit to Orbit
- Test infrastructure with 27 unit tests
- AI Sidecar foundation (OllamaClient, PageContextExtractor, AISidebarView)
- ollama-swift dependency integrated
- AI Sidebar integration with NSSplitViewController
- Keyboard shortcut (⌘⇧A) and toolbar button for sidebar toggle

---

## Phase 1: AI Sidecar Foundation ✅ COMPLETE

**Goal**: Build the core AI integration components.

### 1.1 Ollama Client ✅ DONE
- [x] Add ollama-swift dependency to Package.swift
- [x] Create `OllamaClient.swift` - streaming chat wrapper
- [x] Support page context injection in prompts
- [x] Convenience methods: ask(), summarize(), explain()

### 1.2 Page Context Extraction ✅ DONE
- [x] Create `PageContextExtractor.swift` - JS bridge
- [x] Extract title, URL, selected text, page content
- [x] Clean content (remove scripts, ads, nav)
- [x] WKWebView extension: extractAIContext()

### 1.3 AI Sidebar View ✅ DONE
- [x] Create `AISidebarView.swift` - SwiftUI chat interface
- [x] AISidebarViewModel with ObservableObject
- [x] Message bubbles with user/assistant roles
- [x] Model selector from available Ollama models
- [x] Quick actions: Summarize, Explain Selection
- [x] NSViewController wrapper for AppKit integration

---

## Phase 2: Sidebar Integration ✅ COMPLETE

**Goal**: Integrate AI sidebar into the main browser window.

### 2.1 NSSplitViewController Architecture ✅ DONE
- [x] Create `AISplitViewController.swift` - split view controller
- [x] Refactor main window to use NSSplitViewController
- [x] Add AI sidebar as collapsible split view item (280-400px)
- [x] Implement toggle animation (⌘⇧A shortcut)
- [x] Add toolbar button for AI sidebar
- [x] Wire webView attachment when tabs change

### 2.2 WebView Connection 🔄 NEXT
- [ ] Auto-refresh context on page navigation
- [ ] Pass selected text to sidebar
- [ ] Context menu integration: "Ask Orbit AI"

### 2.3 Settings & Persistence
- [ ] Model selection persistence
- [ ] Ollama endpoint configuration
- [ ] Chat history per-tab (optional)

---

## Phase 3: Content Blocking Polish (Week 3-4)

**Goal**: Make content blocking production-ready.

### 3.1 WebView Integration
- [ ] Add `contentBlocking: Bool` option to MPWebViewConfig
- [ ] Auto-apply default blocking rules on WebView creation
- [ ] JavaScript API: `$.browser.enableAdBlocking()`

### 3.2 Settings Persistence
- [ ] Store blocking preferences in UserDefaults
- [ ] Per-app blocking configuration
- [ ] Global default settings

### 3.3 Testing & Validation
- [ ] Test on CNN.com, Forbes.com, YouTube.com, Reddit.com
- [ ] Verify no site breakage

---

## Phase 4: Network Isolation (Week 5-6)

**Goal**: Per-space network and data isolation.

### 4.1 WKWebsiteDataStore Isolation
- [ ] Create separate data stores per "Space"
- [ ] Isolate cookies, cache, localStorage
- [ ] Settings UI for space management

### 4.2 Proxy Configuration
- [ ] Per-space proxy settings (SOCKS5, HTTP)
- [ ] User-Agent customization
- [ ] Integration with Charles/Proxyman

---

## Phase 5: CSS/JS Injection Engine (Week 7-8)

**Goal**: Persistent userscripts and styles.

### 5.1 Enhanced Injection
- [ ] Create `ScriptInjector.swift` with runtime injection
- [ ] Support Greasemonkey/Tampermonkey metadata blocks
- [ ] File watcher for CSS hot-reload
- [ ] JavaScript API for injection management

### 5.2 Script Management UI
- [ ] List installed scripts per site
- [ ] Enable/disable toggle
- [ ] Editor for custom scripts

### 5.3 Starter Scripts
- [ ] Dark mode for any site
- [ ] YouTube focus (remove distractions)
- [ ] Gmail cleanup

---

## Phase 6: Polish & Release (Week 9-10)

**Goal**: Prepare for public release.

### 6.1 Documentation
- [ ] User guide for creating apps
- [ ] Developer guide for contributing
- [ ] JavaScript API reference
- [ ] AI Sidecar usage guide

### 6.2 Testing
- [ ] macOS 14 (Sonoma) testing
- [ ] macOS 15 (Sequoia) testing
- [ ] arm64 (Apple Silicon)
- [ ] x86_64 (Intel) - stretch goal

### 6.3 Launch Preparation
- [ ] Create demo video
- [ ] Prepare Hacker News post
- [ ] Set up GitHub Sponsors
- [ ] Create landing page

---

## Timeline Summary

| Phase | Focus | Status | Target Date |
|-------|-------|--------|-------------|
| 1 | AI Sidecar Foundation | ✅ COMPLETE | Jan 5, 2026 |
| 2 | Sidebar Integration | ✅ COMPLETE | Jan 5, 2026 |
| 3 | Content Blocking Polish | ⏳ Pending | Feb 2, 2026 |
| 4 | Network Isolation | ⏳ Pending | Feb 16, 2026 |
| 5 | CSS/JS Injection | ⏳ Pending | Mar 2, 2026 |
| 6 | Polish & Release | ⏳ Pending | Mar 16, 2026 |

**v1.0 Target**: March 16, 2026

---

## Recent Commits

- `6ed439c` - feat: add AI Sidecar foundation with Ollama integration
- `2b4dc0d` - feat: add test infrastructure with 27 unit tests
- `beb07b8` - chore: release v0.2.0 - Orbit rebrand release

---

## Development Environment

### Required
- Xcode 15.4+
- Swift 5.10+
- macOS 14.0+
- Ollama (for AI features): `brew install ollama`

### Optional
- Linear CLI: `npm install -g agent2linear` (for project tracking)

---

## File Structure (AI Components)

```
Sources/MacPinOSX/AI/
├── OllamaClient.swift         # Ollama API wrapper (272 lines)
├── PageContextExtractor.swift # JS bridge for page content (166 lines)
├── AISidebarView.swift        # SwiftUI chat interface (405 lines)
└── AISplitViewController.swift # NSSplitViewController integration (101 lines)
```

---

## Resources

- **Ollama Swift**: https://github.com/mattt/ollama-swift
- **WebKit Content Blockers**: https://webkit.org/blog/3476/content-blockers-first-look/
- **Orbit Strategy**: See `PIVOT_STRATEGY.md`

---

**Last Updated**: January 5, 2026  
**Maintainer**: @chindris-mihai-alexandru
