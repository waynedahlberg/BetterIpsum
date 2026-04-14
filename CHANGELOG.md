# Changelog

All notable changes to BetterIpsum are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [Semantic Versioning](https://semver.org/).

---

## [0.9.3] - 2026-04-13

### Added
- Dropdown menu to select placeholder text 'Theme'
- Adjust overall width of the panel (smaller, 256pt)

## [0.9.0] — 2026-04-09

### Added
- Menu bar app with `MenuBarExtra` — no Dock icon
- Copy words (1–5), sentences (1–5), or paragraphs (1–5) to clipboard
- Animated capsule UI with hover-to-select and click-to-copy interaction
- Seven bundled placeholder themes: Culinary Literature, Machine Learning Whitepaper, Marketing Copywriting, Scientific Manuscripts, Corporate Finance, Travel Brochures, Fantasy Quest
- Theme picker in Preferences
- Launch at login toggle via `SMAppService`
- All content served locally from `themes.json` — no network requests
- XcodeGen `project.yml` — `.xcodeproj` is never committed

## [0.9.1] — 2026-04-10

### Refactored
- Settings View. Now a modal window presentation instead of 'push-pop' navigation stack

### Cleaned
- Removed unnecessary and unreferenced files
- Removed unused early prototype views
