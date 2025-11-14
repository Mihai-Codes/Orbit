# WebKitForge Modernization Roadmap

## Project Overview

**WebKitForge** is a modern fork of MacPin - a lightweight, open-source WebKit-based site-specific browser (SSB) framework for macOS.

**Original Repository**: [kfix/MacPin](https://github.com/kfix/MacPin) (339 stars, GPL-3.0, last updated Nov 2022)  
**Fork Repository**: [chindris-mihai-alexandru/MacPin](https://github.com/chindris-mihai-alexandru/MacPin)  
**Branch**: `modernize/swift6-macos15`

### Why WebKitForge?

After attempting to fix Unite/Coherence (closed-source SSB apps) via method swizzling and encountering unfixable deep layout engine bugs, we decided to fork MacPin as an open-source alternative that we can fully control and improve.

---

## Current Status (as of Nov 15, 2025)

### ✅ Build Status: SUCCESS

The codebase **builds successfully** on:
- **Swift**: 6.2.1 (swiftlang-6.2.1.4.8)
- **macOS**: 15.0 (Sequoia)
- **Target**: arm64-apple-macosx15.0
- **Build Time**: ~3.5s

### 📊 Current Stack

- **Swift Version**: 5.4 (declared in Package.swift)
- **Minimum macOS**: 11.0 (Big Sur)
- **Build System**: Swift Package Manager + GNU Make
- **Architecture**: Dynamic Framework + Stub Launcher
- **Dependencies**:
  - `swift-argument-parser` 1.6.2
  - Local: `Linenoise`, `UTIKit`
  - System: `WebKitPrivates`, `JavaScriptCorePrivates`, `ViewPrivates`, `UserNotificationPrivates`

### ⚠️ Known Issues (Warnings Only)

**Deprecations** (15 warnings total):
1. **macOS 11.0 deprecations**:
   - `NSWorkspace.absolutePathForApplication(withBundleIdentifier:)` → Use `URLForApplicationWithBundleIdentifier:`
   
2. **macOS 10.14 deprecations**:
   - `WebKitErrorDomain` (9 occurrences) → Use `WKError.errorDomain`
   
3. **Swift 6 compatibility warnings**:
   - Temporary pointer conversions in `AppScriptRuntime.swift:552`
   - Unused variables (7 occurrences)

**No errors** - codebase is fully functional!

---

## Phase 1: Code Modernization (Week 1-2)

**Goal**: Update to modern Swift & macOS APIs while maintaining backward compatibility testing.

### 1.1 Update Package.swift ✅ Priority: HIGH

**File**: `Package.swift`

**Changes**:
```swift
// Current
swift-tools-version:5.4
platforms: [.macOS(.v11)]

// Target
swift-tools-version:6.0
platforms: [.macOS(.v14)] // Sonoma - good balance of modern + compatibility
```

**Why macOS 14**:
- macOS 15 (Sequoia) is too new - excludes many users
- macOS 14 (Sonoma) released Oct 2023 - good adoption
- macOS 13 (Ventura) still lacks some modern APIs we want
- Keeps Swift 6 strict concurrency features

### 1.2 Fix API Deprecations ✅ Priority: HIGH

#### A. NSWorkspace API Update
**File**: `Sources/MacPin_stub/main.swift:56`

**Before**:
```swift
if let MPappPath = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: "com.github.kfix.MacPin.MacPin"),
```

**After**:
```swift
if let MPappURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.github.kfix.MacPin.MacPin"),
   let MPappPath = MPappURL.path,
```

#### B. WebKitErrorDomain Replacement
**Files**: `Sources/MacPinOSX/shared/WebViewDelegates.swift` (9 locations)

**Before**:
```swift
if error._domain == WebKitErrorDomain && error._code == kWKErrorCodePlugInWillHandleLoad {
```

**After**:
```swift
if error._domain == WKError.errorDomain && error._code == WKError.Code.plugInWillHandleLoad.rawValue {
```

**Pattern**: Replace all `WebKitErrorDomain` with `WKError.errorDomain`

#### C. JSContext C String Issue
**File**: `Sources/MacPinOSX/shared/AppScriptRuntime.swift:552`

**Before**:
```swift
className: "MPGlobalObject", parentClass: nil,
```

**After**:
```swift
className: "MPGlobalObject".withCString { $0 }, parentClass: nil,
```

**OR** (preferred - static lifetime):
```swift
static let className = ("MPGlobalObject" as NSString).utf8String
// Then use:
className: Self.className, parentClass: nil,
```

### 1.3 Clean Up Unused Variables ✅ Priority: MEDIUM

Fix 7 warnings about unused variables:
- Replace with `_` for intentionally unused
- Remove if truly unnecessary
- Use value if it was meant to be used

**Locations**:
- `Sources/MacPin_stub/main.swift:46` - `sharedURL`
- `Sources/MacPinOSX/shared/WebViewDelegates.swift:397` - `scheme`
- `Sources/MacPinOSX/shared/WebViewDelegates.swift:398` - unused `popup()` result

### 1.4 Update Build Configuration ✅ Priority: MEDIUM

**File**: `Makefile`

Update version and metadata:
```makefile
VERSION := 1.0.0-alpha  # Start fresh
template_bundle_id := org.webkitforge.WebKitForge  # Rebrand
```

---

## Phase 2: Feature Additions (Week 3-6)

**Goal**: Add features that make WebKitForge better than Unite/Coherence.

### 2.1 Fix Tab Management Issues ✅ Priority: HIGH

**Problem**: Unite 6.5 has unfixable tab visibility bugs (the reason we started this project!)

**Implementation**:
1. Review `Sources/MacPinOSX/BrowserViewControllerOSX.swift`
2. Review `Sources/MacPinOSX/TabFlowController.swift`
3. Ensure tab bar height is consistently enforced
4. Add drag-and-drop tab rearranging (broken in Unite)
5. Add keyboard shortcuts for tab navigation

**Success Criteria**:
- Tabs visible at all times
- Smooth drag-and-drop reordering
- Cmd+1-9 for tab switching
- Cmd+Shift+[ / ] for prev/next tab

### 2.2 GUI App Creator ✅ Priority: HIGH

**Problem**: Current MacPin requires CLI + manual icon/config setup.

**Solution**: SwiftUI-based app builder

**Files to Create**:
- `Sources/WebKitForgeBuilder/` (new directory)
- `Sources/WebKitForgeBuilder/BuilderApp.swift` - SwiftUI app
- `Sources/WebKitForgeBuilder/Models/AppConfig.swift` - SSB configuration
- `Sources/WebKitForgeBuilder/Views/MainBuilderView.swift` - Main interface

**Features**:
- URL input with validation
- App name input
- Icon import (drag-and-drop or file picker)
- Icon generation from URL favicon
- Live preview
- "Create App" button → generates `.app` bundle
- Optional: JavaScript injection editor
- Optional: Custom CSS editor

**UI Mockup**:
```
┌─────────────────────────────────────┐
│ WebKitForge App Builder             │
├─────────────────────────────────────┤
│ App URL:  [https://example.com   ] │
│ App Name: [Example              ] │
│                                      │
│ Icon:     [Drop icon here]           │
│           or generate from favicon   │
│                                      │
│ Advanced Options ▾                   │
│   [ ] Enable Developer Tools         │
│   [ ] Custom User Agent             │
│   [ ] Inject JavaScript             │
│   [ ] Custom CSS                    │
│                                      │
│           [Create App]               │
└─────────────────────────────────────┘
```

**Add to Package.swift**:
```swift
.executable(name: "WebKitForgeBuilder", targets: ["WebKitForgeBuilder"]),
```

### 2.3 Improved App Bundling ✅ Priority: MEDIUM

**Current Issue**: Apps depend on external `MacPin.framework`

**Goal**: Self-contained apps OR shared framework in ~/Library

**Options**:

**A. Embedded Framework** (Preferred)
- Bundle `MacPin.framework` inside each `.app/Contents/Frameworks/`
- Increases app size (~4MB per app) but apps are portable
- No system-wide installation needed

**B. System Framework**
- Install `MacPin.framework` to `~/Library/Frameworks/`
- All apps share one framework copy
- Requires installer/updater

**Implementation**:
- Update `Makefile` bundling logic
- Test code signing with embedded framework
- Ensure `@rpath` is correct

### 2.4 Notarization Support ✅ Priority: MEDIUM

**Goal**: Apps pass Gatekeeper without "unidentified developer" warnings.

**Requirements**:
- Apple Developer Account ($99/year)
- Hardened runtime
- Secure timestamp
- Notarization API integration

**Files to Update**:
- `Makefile` - add notarization targets
- `templates/macos/entitlements.plist` - add hardened runtime entitlements

**New Make Targets**:
```makefile
notarize-%.app: $(appdir)/%.app
    xcrun notarytool submit $< --keychain-profile "AC_PASSWORD" --wait
    xcrun stapler staple $<
```

---

## Phase 3: UI/UX Polish (Week 7-8)

**Goal**: Modern macOS 14/15 native experience.

### 3.1 macOS 14/15 Native UI ✅ Priority: MEDIUM

**Updates**:
- Use SF Symbols for icons
- Adopt macOS 14 menu bar styling
- Add vibrancy effects for sidebar/tabs
- Support macOS 15 accent colors

**Files**:
- `Sources/MacPinOSX/WindowController.swift`
- `Sources/MacPinOSX/BrowserViewControllerOSX.swift`

### 3.2 Settings/Preferences Panel ✅ Priority: LOW

**Current**: Settings are JavaScript-driven via `main.js`

**Improvement**: Native SwiftUI settings panel

**Features**:
- Default search engine
- Download location
- Privacy settings (cookies, storage)
- Developer tools toggle
- Auto-update settings

### 3.3 Better Icon Generation ✅ Priority: LOW

**Current**: `Tools/iconify` uses `xcrun actool`

**Improvements**:
- Automatic favicon download from URL
- Icon scaling/centering for non-square images
- Background color picker for transparent icons
- macOS 14 icon template support

---

## Phase 4: Testing & Documentation (Week 9-10)

### 4.1 Automated Testing ✅ Priority: MEDIUM

**Add Tests**:
```
Tests/
├── WebKitForgeTests/
│   ├── AppScriptRuntimeTests.swift
│   ├── WebViewDelegatesTests.swift
│   └── TabManagementTests.swift
└── WebKitForgeBuilderTests/
    └── AppConfigTests.swift
```

**Test Targets**:
- JavaScript bridge functionality
- Tab management logic
- App configuration validation
- Icon generation

### 4.2 Documentation ✅ Priority: HIGH

**Files to Create/Update**:
- `README.md` - Complete rewrite
- `CONTRIBUTING.md` - Development guide
- `docs/` directory:
  - `docs/building-apps.md` - User guide for creating apps
  - `docs/development.md` - Contributor guide
  - `docs/api-reference.md` - JavaScript API docs
  - `docs/troubleshooting.md` - Common issues

### 4.3 Example Apps ✅ Priority: LOW

**Update `sites/` directory**:
- Modernize existing example apps
- Add new examples:
  - `sites/ChatGPT/` - AI assistant
  - `sites/Linear/` - Project management
  - `sites/Notion/` - Note-taking
  - `sites/Figma/` - Design tool

---

## Phase 5: Release Preparation (Week 11-12)

### 5.1 Branding ✅ Priority: HIGH

**Rename Everything**:
- `MacPin` → `WebKitForge`
- `com.github.kfix.MacPin` → `org.webkitforge.WebKitForge`
- Update all files, comments, docs

**Files Affected**: ~50+ files

**Strategy**: Use `replaceAll` in edit tool

### 5.2 GitHub Release ✅ Priority: HIGH

**Deliverables**:
1. `WebKitForge-macos-arm64-1.0.0.dmg` - App builder + framework
2. `WebKitForge-macos-arm64-1.0.0.zip` - Same as DMG
3. `WebKitForge-universal-1.0.0.dmg` - Universal binary (arm64 + x86_64)

**Release Notes Template**:
```markdown
# WebKitForge 1.0.0

First stable release of WebKitForge, a modern WebKit-based SSB framework.

## Features
- ✅ Native macOS 14+ support
- ✅ Swift 6.0
- ✅ GUI App Builder
- ✅ Fixed tab management (better than Unite!)
- ✅ Self-contained apps
- ✅ Notarization support

## Download
- [WebKitForge-macos-arm64-1.0.0.dmg](...)
- [WebKitForge-universal-1.0.0.dmg](...)
```

### 5.3 Website ✅ Priority: MEDIUM

**Domain**: `webkitforge.org` (or similar)

**Pages**:
- Home - Feature showcase
- Download - Latest release
- Docs - User + dev guides
- Examples - Screenshot gallery

**Tech**: Static site (Hugo/Jekyll) hosted on GitHub Pages

---

## Success Metrics

### Phase 1 (Modernization)
- ✅ Zero build errors
- ✅ Zero deprecation warnings
- ✅ Passes macOS 14/15 compatibility tests

### Phase 2 (Features)
- ✅ GUI app builder creates working apps
- ✅ Tab management has no visibility bugs
- ✅ Apps are self-contained and portable

### Phase 3 (Polish)
- ✅ UI looks native on macOS 14/15
- ✅ Users prefer WebKitForge over Unite/Coherence

### Phase 4 (Testing)
- ✅ Test coverage >70%
- ✅ Documentation is complete

### Phase 5 (Release)
- ✅ 1.0.0 tagged on GitHub
- ✅ 100+ stars within 3 months
- ✅ 10+ community contributors

---

## Future Enhancements (Post-1.0)

### Multi-Tab Apps
- Allow single app to have multiple permanent tabs
- Example: Gmail app with Mail, Calendar, Contacts tabs

### Notification Badge Support
- Show unread counts on Dock icon
- Requires webpage JavaScript API

### Menu Bar Apps
- Lightweight apps that live in menu bar
- Click to show popup window (like Slack)

### Extension Support
- Safari-like extensions
- User scripts repository
- Adblocker built-in

### iOS Version
- Port to iOS/iPadOS
- Share core WebKit wrapper code

### Windows/Linux Ports
- GTK+ WebKit2 for Linux
- Edge WebView2 for Windows
- Cross-platform app definitions

---

## Timeline Summary

| Phase | Duration | Completion Date |
|-------|----------|----------------|
| 1. Modernization | 2 weeks | Nov 29, 2025 |
| 2. Features | 4 weeks | Dec 27, 2025 |
| 3. Polish | 2 weeks | Jan 10, 2026 |
| 4. Testing | 2 weeks | Jan 24, 2026 |
| 5. Release | 2 weeks | Feb 7, 2026 |

**v1.0.0 Target**: February 7, 2026

---

## Immediate Next Steps (This Week)

1. ✅ Update `Package.swift` to Swift 6.0 + macOS 14
2. ✅ Fix all deprecation warnings (15 total)
3. ✅ Test build and run sample app
4. ✅ Commit modernization changes
5. ✅ Start GUI app builder prototype

---

## Questions to Answer

1. **Licensing**: Keep GPL-3.0 or switch to MIT/Apache 2.0?
   - **Decision**: Keep GPL-3.0 to honor original
   
2. **Notarization**: Wait for paid account or release unsigned first?
   - **Decision**: Release unsigned with instructions for users
   
3. **Universal Binary**: Support x86_64 or arm64-only?
   - **Decision**: Start arm64-only, add universal later if requested
   
4. **Backward Compat**: Support macOS 13 (Ventura)?
   - **Decision**: No - target macOS 14+ for modern APIs

---

## Resources

- **Original MacPin Repo**: https://github.com/kfix/MacPin
- **WebKit Documentation**: https://webkit.org/documentation/
- **Swift Argument Parser**: https://github.com/apple/swift-argument-parser
- **Notarization Guide**: https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution

---

**Last Updated**: November 15, 2025  
**Maintainer**: @chindris-mihai-alexandru
