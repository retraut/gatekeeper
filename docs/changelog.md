# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0](https://github.com/retraut/gatekeeper/compare/v0.1.0...v0.2.0) (2025-12-30)


### Features

* Initial Gatekeeper release with CLI and daemon ([2d7895d](https://github.com/retraut/gatekeeper/commit/2d7895d7938ad0ed18b0e02aefbde5d20e0ecf19))


### Bug Fixes

* add checkout step to release workflow for proper PR creation ([e236287](https://github.com/retraut/gatekeeper/commit/e2362876069d3c37f2940610f05f93fbb1160414))
* add issues write permission for release-please action ([4969985](https://github.com/retraut/gatekeeper/commit/4969985e0e0b853af8b7deef69eda50a82b8065c))

## [Unreleased]

### Added
- Initial release of Gatekeeper CLI
- Service authentication status monitoring daemon
- YAML configuration support
- CLI status commands (compact, json, plaintext output)
- HTTP health check endpoint
- tmux integration for status display
- macOS menu bar application
- WidgetKit support for desktop/lock screen widgets
