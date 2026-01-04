# Orbit: The AI-Augmented Browser Workspace

## Executive Summary

**Orbit** is a macOS-native browser workspace that provides features Safari's "Add to Dock" cannot offer: Local AI integration, per-app network tunneling, and deep web app customization.

This document outlines the strategic pivot from PWA-Kit (a lightweight Safari PWA alternative) to Orbit (a power-user browser workspace with AI capabilities).

---

## Why the Pivot?

### The Problem with PWA-Kit's Original Vision

1. **Apple Solved the Core Problem**: Starting with macOS Sonoma (14.0), Safari's "Add to Dock" creates proper, first-class PWAs with Web Push, Badging, Service Workers, and native integration.

2. **RAM Savings Aren't Compelling**: The 100-200MB RAM savings per app don't justify the development effort for most users.

3. **Pake Already Won**: The Rust/Tauri-based [Pake](https://github.com/tw93/Pake) has 44k+ stars and handles the "lightweight wrapper" use case better for cross-platform needs.

### The Opportunity

Safari PWAs are **dumb windows**. They lack:
- AI assistance that understands page context
- Per-app network configuration (proxies, VPNs)
- Deep customization (persistent CSS/JS injection)
- Developer debugging tools per-app

**Orbit fills this gap by being the "Power Tool" browser for professionals.**

---

## Strategic Positioning

### Orbit vs. Competitors

| Tool | Purpose | Platform | Price | Our Advantage |
|------|---------|----------|-------|---------------|
| Safari "Add to Dock" | Basic PWA creation | macOS | Free | We offer AI + Network + Mods |
| Pake | Cross-platform wrapper | All | Free | We're macOS-native with deep features |
| Unite/Coherence | Polished SSB | macOS | $25-30 | We're open-source + AI-powered |
| AI Browsers (Dia, Comet) | Full browser replacement | Various | Varies | We're focused, per-app workspaces |

### Target Users

1. **Developers**: Need per-app proxy routing (Charles/Proxyman), isolated debugging
2. **Power Users**: Want AI assistance without data leaving their Mac
3. **Customizers**: Need persistent CSS/JS fixes for enterprise apps (Jira, Salesforce, AWS Console)
4. **Privacy-Conscious**: Local AI, no cloud dependency

---

## Core Feature Set

### 1. Local AI Sidecar (Primary Differentiator)

**What**: A collapsible sidebar that connects to local LLMs (Ollama, LM Studio) to interact with page content.

**Use Cases**:
- "Summarize this Jira ticket"
- "Draft a reply to this email"
- "Analyze this GitHub PR"
- "Explain this AWS error"

**Technical Implementation**:
```
Architecture:
+------------------+     +------------------+
|    WebView       |<--->|   AI Sidebar     |
|  (WKWebView)     |     |   (SwiftUI)      |
+------------------+     +------------------+
         |                        |
         v                        v
+------------------+     +------------------+
| PageContext      |     | Ollama Client    |
| Extractor (JS)   |     | (localhost:11434)|
+------------------+     +------------------+
```

**Key Components**:
- `NSSplitViewController` for main view + sidebar
- `WKScriptMessageHandler` for JS-Swift bridge
- `PageContextExtractor.swift` - extracts DOM text via injected JS
- `OllamaClient.swift` - handles streaming responses from local LLM

**Why Safari Can't Do This**: Extensions are sandboxed with limited UI. Orbit owns the window.

### 2. Network Tunneling (Technical Moat)

**What**: Assign a specific SOCKS5 proxy or User-Agent to individual app windows.

**Use Cases**:
- QA testing from different geo-locations
- Route only one app through debugging proxy (Charles/Burp)
- Bypass geo-blocks on specific services without system-wide VPN

**Technical Implementation**:
- `WKWebsiteDataStore` for cookie/storage isolation per "Space"
- `NEAppProxyProvider` (Network Extension) for PID-scoped proxy
- Custom `URLProtocol` swizzling for request modification

### 3. "God Mode" Injection (Community Moat)

**What**: Persistent UserScripts and UserStyles that sync via iCloud.

**Use Cases**:
- Fix terrible enterprise UI (Jira dark mode, Salesforce cleanup)
- Remove distractions (YouTube shorts, Gmail ads)
- Add missing features to web apps

**Technical Implementation**:
- `WKUserContentController` for script injection at `.documentStart`
- CSS hot-reloading via file watching + style tag replacement
- iCloud Drive sync for scripts across Macs

---

## Monetization Strategy

### Open Core Model

**Free (GPL-3.0)**:
- Basic SSB creation
- Network isolation (basic cookie separation)
- Simple script injection

**Pro License ($29 one-time or $4/month)**:
- AI Sidecar integration
- Advanced networking (proxy chaining, headers modification)
- Cloud sync for scripts/styles
- Priority support

### Revenue Projections (Realistic)

| Year | Users | Conversion | Revenue |
|------|-------|------------|---------|
| Year 1 | 500 | 10% | $1,450 |
| Year 2 | 2,000 | 15% | $8,700 |
| Year 3 | 5,000 | 20% | $29,000 |

*Note: These are conservative estimates assuming organic growth. The previous MONETIZATION.md projections of $20-50k in Year 1-2 were overly optimistic without product-market fit.*

---

## Technical Roadmap

### Phase 1: Rebrand & Stabilize (Q1 2026)
- [x] Rename PWA-Kit to Orbit
- [ ] Update README, branding, documentation
- [ ] Fix MacPin PR review issues (security email, CI tests)
- [ ] Complete Swift 5.10/macOS 14 modernization
- [ ] Create GitHub repo: `chindris-mihai-alexandru/Orbit`

### Phase 2: AI Sidecar MVP (Q1-Q2 2026)
- [ ] Implement `NSSplitViewController` sidebar architecture
- [ ] Create `PageContextExtractor` (JS injection)
- [ ] Build `OllamaClient` with streaming support
- [ ] Add Settings UI for model configuration
- [ ] Test with 3-5 common web apps (Gmail, GitHub, Jira)

### Phase 3: Network Features (Q2 2026)
- [ ] Implement `WKWebsiteDataStore` isolation per Space
- [ ] Add proxy configuration UI
- [ ] Test with Charles/Proxyman integration

### Phase 4: Script Marketplace (Q3 2026)
- [ ] Build robust CSS/JS injection UI
- [ ] Implement iCloud sync for scripts
- [ ] Create starter pack of popular fixes
- [ ] Launch "Orbit Scripts" Gumroad store

### Phase 5: Pro Launch (Q3-Q4 2026)
- [ ] Implement license verification
- [ ] Create Gumroad/Paddle integration
- [ ] Launch marketing campaign
- [ ] Build documentation site

---

## Relationship with PakePlus

**Orbit** and **PakePlus** (our Pake fork) are **separate projects** with different purposes:

| Aspect | Orbit | PakePlus |
|--------|-------|----------|
| Tech Stack | Swift/WebKit | Rust/Tauri |
| Platform | macOS only | macOS, Windows, Linux |
| Purpose | Power-user workspace | Quick app packaging |
| Complexity | Feature-rich | Lightweight |
| Target | Developers, power users | General distribution |

**Why Both?**:
- Use **PakePlus** to quickly wrap a site for distribution
- Use **Orbit** as your personal productivity tool with AI/network features

---

## Success Metrics

### 6-Month Goals
- [ ] 100 GitHub stars on Orbit repo
- [ ] AI Sidecar working with 5+ web apps
- [ ] 10 beta testers providing feedback
- [ ] First PR from external contributor

### 12-Month Goals
- [ ] 500 GitHub stars
- [ ] Pro license generating $100+/month
- [ ] Featured in one macOS developer blog/newsletter
- [ ] 50 active daily users

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Apple adds AI to Safari PWAs | Medium | High | Our network features remain unique |
| Ollama changes API | Low | Medium | Abstract LLM interface to support multiple backends |
| No user interest | Medium | High | Validate with beta testers before heavy development |
| Development time | High | Medium | Prioritize AI sidecar as the single killer feature |

---

## References

### Competitive Intelligence
- [Agentic Browsers in 2025](https://o-mega.ai/articles/agentic-browsers-in-2025-atlas-neon-comet-dia-full-comparison)
- [Pake GitHub](https://github.com/tw93/Pake) - 44k+ stars
- [Safari 26 WebKit updates](https://webkit.org/blog/16993/news-from-wwdc25-web-technology-coming-this-fall-in-safari-26-beta/)

### Technical Resources
- [WebKit for SwiftUI (WWDC25)](https://developer.apple.com/videos/play/wwdc2025/231/)
- [Ollmao - SwiftUI Ollama integration](https://github.com/LinkScapeOfficial/Ollmao)
- [Building Local Ollama App with Swift](https://medium.com/codex/building-a-local-llama-3-app-for-your-mac-with-swift-e96f3a77c0bb)

---

## Action Items for AI Coding Model

When implementing Orbit features, follow this priority:

1. **First**: Implement AI Sidecar (the differentiating feature)
   - Start with `NSSplitViewController` refactor
   - Build `OllamaClient.swift` for API communication
   - Create `PageContextExtractor` JS bridge

2. **Second**: Network isolation
   - `WKWebsiteDataStore` per-space isolation
   - Proxy configuration UI

3. **Third**: Script injection system
   - Persistent UserScripts/UserStyles
   - File watching for hot-reload

**Do NOT** try to compete with Pake on lightweight packaging. That's what PakePlus is for.

---

*Last Updated: January 4, 2026*
*Document Version: 1.0*
