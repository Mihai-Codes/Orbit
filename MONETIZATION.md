# PWA-Kit Monetization Strategy

**Date**: November 16, 2025  
**Status**: Planning Phase
**Model**: Open Core + Services

---

## Core Principle: Keep PWA-Kit Open-Source

### Legal Reality
PWA-Kit **MUST** remain open-source (GPL-3.0) because:
1. It's a fork of kfix/MacPin (GPL-3.0 licensed)
2. GPL is "copyleft" - once released, it cannot be made proprietary
3. Anyone who has cloned the repo legally owns the GPL code forever
4. Violating GPL would be copyright infringement

### Strategic Benefit
Keeping PWA-Kit open-source is actually **better for monetization**:
- Builds credibility and community trust
- Attracts corporate sponsors (prefer transparent OSS)
- Drives traffic to paid products
- Creates ecosystem around the tool

---

## Monetization Streams

### 1. GitHub Sponsors (Primary Funding)
**Platform**: GitHub Sponsors (0% platform fee)
**Target**: Individual developers + corporate sponsors

**Tiers**:
- **$5/month** - Supporter
  - Name in README contributors section
  - Early access to release notes
  
- **$25/month** - Contributor
  - Priority issue responses (24-48 hour SLA)
  - Monthly Q&A session
  - Vote on feature prioritization
  
- **$100/month** - Business
  - Logo on PWA-Kit website
  - 2 hours consulting/month
  - Direct Slack/Discord channel
  
- **$500/month** - Enterprise
  - Dedicated support email
  - Feature prioritization
  - Custom integrations consulting
  - SLA for critical bugs

**Projected Revenue**: $500-1,500/month within 6 months

**Setup Tasks**:
- [ ] Enable GitHub Sponsors
- [ ] Create tier descriptions
- [ ] Add sponsor badges to README
- [ ] Set up OpenCollective for transparent finances

---

### 2. PWAKitBuilder (Proprietary GUI App)
**Platform**: Separate macOS app (closed-source)
**Distribution**: Gumroad + Direct download
**Tech Stack**: Swift + SwiftUI

### What PWAKitBuilder Does
Visual GUI for creating PWAs without using the command line:
- Drag-drop URL and icon input
- Automatic favicon fetching
- Live preview of PWA
- Template library (Gmail, Slack, Twitter configs)
- Cloud sync for PWA configurations (premium)
- Export to .app bundle with one click

### Legal Strategy
PWAKitBuilder is **NOT a fork** of PWA-Kit - it's a **new proprietary application** that:
- Calls PWA-Kit CLI as a dependency (like VSCode uses Git)
- Adds GUI layer on top (100% original code)
- Can be closed-source because it doesn't modify GPL code
- Uses PWA-Kit as a library, not a base

### Pricing Strategy
**Model**: Pay-What-You-Want (PWYW) with suggested price

Research shows PWYW generates 2-4x more revenue than fixed pricing:
- **Suggested**: $29
- **Minimum**: $0 (try free)
- **Average payment**: ~$18 (30% pay $0, 50% pay $15-35, 20% pay $50+)

**Alternative**: Freemium subscription
- Free tier: Basic PWA creation (uses PWA-Kit CLI)
- $9/month: GUI app + cloud sync + premium templates

**Timeline**:
- **Month 1-2**: Design and prototype
- **Month 3-4**: Build core features
- **Month 5-6**: Beta testing with sponsors
- **Month 7**: Public launch on Gumroad

**Projected Revenue**: $500-2,000/month after launch

---

### 3. Gumroad Product - PWAKitBuilder App
**Platform**: Gumroad (10% + 3.5% fees)
**Product**: PWAKitBuilder.app - macOS GUI Application

**What is PWAKitBuilder**:
- Beautiful SwiftUI desktop application for creating PWAs
- Visual drag-and-drop interface (no command line needed)
- Automatic favicon fetching and icon generation
- Template library (Gmail, Slack, Twitter, Discord, etc.)
- Live PWA preview before creation
- One-click "Create App" button
- **THIS IS WHAT YOU SELL** - an actual Mac app, not courses

**Why it's legal to sell**:
- PWAKitBuilder is a NEW proprietary SwiftUI app
- NOT a fork of PWA-Kit (separate codebase)
- Uses PWA-Kit CLI "under the hood" as a tool
- Like how Tower (paid GUI) uses Git CLI (free)
- Completely legal to sell closed-source GUI app

**Pricing**: Pay-What-You-Want (PWYW)
- **Suggested**: $29
- **Minimum**: $0 (try free)
- **Average expected**: ~$18-22 per sale

**Revenue Projection**:
- Year 1: 200-300 sales × $20 avg = $4,000-6,000
- Year 2: 500-800 sales × $22 avg = $11,000-17,600

**NOT selling on Gumroad**:
- ❌ Courses (low margin, high effort)
- ❌ Templates (just include free in the app)
- ❌ Ebooks (not our strength)
- ✅ ONLY the GUI application itself

---

### 4. Professional Services
**Model**: Consulting and custom development
**Rate**: $100-200/hour

**Services**:
- Custom PWA development for clients
- Enterprise support contracts
- Training workshops
- White-label PWA solutions

**Target Clients**:
- Small businesses wanting custom PWAs
- Agencies needing PWA expertise
- Enterprise teams migrating from Electron

**Projected Revenue**: $500-1,500/month (part-time)

---

## Revenue Projections

### Year 1 Timeline

| Month | GitHub Sponsors | PWAKitBuilder | Gumroad | Services | Total |
|-------|----------------|---------------|----------|----------|-------|
| 1-2   | $200           | $0            | $0       | $200     | $400  |
| 3-4   | $400           | $0            | $200     | $300     | $900  |
| 5-6   | $600           | $0            | $300     | $400     | $1,300|
| 7-8   | $800           | $500          | $400     | $500     | $2,200|
| 9-10  | $1,000         | $1,200        | $500     | $600     | $3,300|
| 11-12 | $1,200         | $1,800        | $600     | $600     | $4,200|

**Year 1 Total**: ~$20,000
**Year 2 Target**: $50,000+ (with established reputation)

---

## Comparison: Why NOT Gumroad Closed-Source

Your original idea was to make PWA-Kit private and sell it on Gumroad. Here's why that's worse:

### Legal Problems
- GPL license cannot be revoked
- Anyone with the public fork keeps it forever
- Selling closed-source = copyright violation
- Potential lawsuits from OSS community

### Financial Problems
- Gumroad fees: 10% + 3.5% = 13.5% per sale
- GitHub Sponsors fees: 3% (saves 10.5% per transaction!)
- One-time sales vs recurring revenue
- Harder to build trust without open source

### Strategic Problems
- Lose all community contributions
- Lose corporate sponsorship potential
- Damage reputation in OSS community
- Competitors can fork the public version anyway

**Bottom line**: Open-source + complementary products = more profitable AND legal

---

## Action Items

### This Month (November 2025)
- [x] Decide to keep PWA-Kit open-source (done)
- [x] Address CodeQL security alerts (done)
- [ ] Set up GitHub Sponsors page
- [ ] Design PWAKitBuilder UI mockups
- [ ] Write first Gumroad course outline

### Next Month (December 2025)
- [ ] Launch GitHub Sponsors
- [ ] Start building PWAKitBuilder prototype
- [ ] Create first 3 premium templates
- [ ] Write CONTRIBUTING.md for PWA-Kit

### Q1 2026
- [ ] Launch PWAKitBuilder beta
- [ ] Release Gumroad course
- [ ] Reach $1,000/month MRR
- [ ] Get first enterprise sponsor

---

## Success Metrics

### GitHub Stars
- Month 3: 100 stars
- Month 6: 500 stars
- Month 12: 1,000 stars

### Revenue
- Month 6: $1,000/month
- Month 12: $3,000/month
- Year 2: $5,000/month

### Community
- Month 6: 5+ community PRs
- Month 12: 10+ contributors
- Year 2: Self-sustaining community

---

## Lessons from Successful OSS Projects

### Red Hat (Linux)
- Open-source core
- $3+ billion/year revenue
- Services + enterprise support model

### Automattic (WordPress)
- Open-source CMS
- $500+ million/year
- Hosting + premium themes/plugins

### GitLab
- Open core model
- Went public at $15B valuation
- Free community edition + paid enterprise

**Common pattern**: Open core + valuable services = sustainable business

---

## References

- GitHub Sponsors: https://github.com/sponsors
- Gumroad for creators: https://gumroad.com
- Open core licensing: https://blog.opentap.io/dual-licensing-open-source-software
- GPL compliance: https://www.gnu.org/licenses/gpl-faq.html
- PWYW pricing research: https://www.forbes.com/sites/quora/2015/05/29/you-can-earn-as-much-or-more-from-a-pay-what-you-want-model

---

**Last Updated**: November 16, 2025
**Next Review**: December 1, 2025
