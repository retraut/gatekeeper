# Changelog

## [0.7.3](https://github.com/retraut/gatekeeper/compare/v0.7.2...v0.7.3) (2026-01-01)


### Bug Fixes

* bump version to 0.7.3 ([97c395f](https://github.com/retraut/gatekeeper/commit/97c395fd04b44ca2e26998f6f207c168910be4f6))
* use git clone with token in URL for brew tap push ([e39a50b](https://github.com/retraut/gatekeeper/commit/e39a50be4d6e370a5d942b731939ef42731c00e9))

## [0.7.2](https://github.com/retraut/gatekeeper/compare/v0.7.1...v0.7.2) (2026-01-01)


### Bug Fixes

* bump version to 0.7.2 ([ee6b133](https://github.com/retraut/gatekeeper/commit/ee6b13357c64b62195b5ec40d0304b774e41c291))
* consolidate release workflow - build and brew update in one run ([0ffc1d6](https://github.com/retraut/gatekeeper/commit/0ffc1d69c3555fe3b102dea8123bd60559900029))

## [0.7.1](https://github.com/retraut/gatekeeper/compare/v0.7.0...v0.7.1) (2026-01-01)


### Bug Fixes

* add version display to --help output ([a80053f](https://github.com/retraut/gatekeeper/commit/a80053f5458aa06948a7a60f0e34dabf37838dbe))
* use HOMEBREW_TAP_TOKEN for pushing to tap repository ([6c84387](https://github.com/retraut/gatekeeper/commit/6c8438729419d4b2c162ba89fc5a80bd83375883))

## [0.7.0](https://github.com/retraut/gatekeeper/compare/v0.6.1...v0.7.0) (2026-01-01)


### Features

* remove macOS app, improve error handling, add validation ([49b5ce5](https://github.com/retraut/gatekeeper/commit/49b5ce5eb11233ec539d046330130d3b1b0ff731))

## [0.6.1](https://github.com/retraut/gatekeeper/compare/v0.6.0...v0.6.1) (2026-01-01)


### Bug Fixes

* verify daemon process is actually running in status command ([e4f04aa](https://github.com/retraut/gatekeeper/commit/e4f04aa3a206cd275f7a139ff7f226482e7388e6))

## [0.5.2](https://github.com/retraut/gatekeeper/compare/v0.5.1...v0.5.2) (2025-12-30)


### Bug Fixes

* improve release workflow architecture ([a4e1137](https://github.com/retraut/gatekeeper/commit/a4e1137e2706c069523beea024b5072314718b56))
* separate release-please and publish-release into independent triggers ([d93fbb7](https://github.com/retraut/gatekeeper/commit/d93fbb7f19f5c0ecfb47433d0322bf13b757d9b8))

## [0.5.1](https://github.com/retraut/gatekeeper/compare/v0.5.0...v0.5.1) (2025-12-30)


### Bug Fixes

* update brew formula workflow to use workflow_run trigger ([eb17db6](https://github.com/retraut/gatekeeper/commit/eb17db687f0cfd4aca0c489ce9cc95a9c88d7186))

## [0.5.0](https://github.com/retraut/gatekeeper/compare/v0.4.2...v0.5.0) (2025-12-30)


### Features

* add 'gatekeeper stop' command to gracefully stop daemon ([b57870c](https://github.com/retraut/gatekeeper/commit/b57870c56f4ff682a0e92cfeb24f01c843e05b24))
* add daemon status to state - show uptime, PID, and last check time ([1c5fa66](https://github.com/retraut/gatekeeper/commit/1c5fa66cebdb8e274d1189d94395ac862cae0314))
* auto-merge brew formula update PR on release ([9b4fd6d](https://github.com/retraut/gatekeeper/commit/9b4fd6def778e2cf6e7d36ca189662c05eff68dd))
* Initial Gatekeeper release with CLI and daemon ([2d7895d](https://github.com/retraut/gatekeeper/commit/2d7895d7938ad0ed18b0e02aefbde5d20e0ecf19))


### Bug Fixes

* add --repo option to gh pr merge for detached HEAD ([71af873](https://github.com/retraut/gatekeeper/commit/71af8734a559f1d0aa53dc9784733a6c29d95e53))
* add --skip-existing to gh release download ([06bc499](https://github.com/retraut/gatekeeper/commit/06bc49991d9ede496a0af330f0e0e35f3b909b5b))
* add checkout step to release workflow for proper PR creation ([e236287](https://github.com/retraut/gatekeeper/commit/e2362876069d3c37f2940610f05f93fbb1160414))
* add issues write permission for release-please action ([4969985](https://github.com/retraut/gatekeeper/commit/4969985e0e0b853af8b7deef69eda50a82b8065c))
* correct YAML heredoc delimiter in workflow ([42fb69f](https://github.com/retraut/gatekeeper/commit/42fb69fe681ef352cfefa8cf9034e0e82f8f3a31))
* correct YAML indentation in release workflow ([f7bf2ba](https://github.com/retraut/gatekeeper/commit/f7bf2ba84694c2cd777fb46f070ff0abcf6a935a))
* don't auto-delete PID file - clean up only when daemon stops ([9bc8ec1](https://github.com/retraut/gatekeeper/commit/9bc8ec18e660a02ea840c4364b7c0337c9fb0dbe))
* handle already-stopped daemon gracefully in stop command ([2deba93](https://github.com/retraut/gatekeeper/commit/2deba930def4091091de4c4582035976ba3b3219))
* improve changelog documentation ([572f497](https://github.com/retraut/gatekeeper/commit/572f497859ad1dd3b602435609273c1f22270e06))
* remove unnecessary 'daemon' alias - use 'start' command only ([1c94ebd](https://github.com/retraut/gatekeeper/commit/1c94ebd7eb0b1561bcf844994572f68ae32add9a))
* simplify release workflow - remove complex homebrew update step ([215e842](https://github.com/retraut/gatekeeper/commit/215e8421ae70cc3f92e07768c0039e7797f68b92))
* specify base branch for create-pull-request action ([f04b6af](https://github.com/retraut/gatekeeper/commit/f04b6affe2679e13f5f17e5c7317a0738a221d3c))
* update changelog with recent improvements ([8f2cc96](https://github.com/retraut/gatekeeper/commit/8f2cc960f999cd4d7c7f2ec025188205ebf87484))
* use pipe delimiter in sed for SHA256 substitution ([61bc1ba](https://github.com/retraut/gatekeeper/commit/61bc1babe58679a22d5cc0675f5d55e02052c626))
* use proper heredoc with sed substitution for workflow variables ([79002f7](https://github.com/retraut/gatekeeper/commit/79002f7fd4af864586cf24f5cf0cc2dd83ffeac8))
* use python instead of shell heredoc to avoid YAML parsing issues ([d426f3f](https://github.com/retraut/gatekeeper/commit/d426f3f39f54b61cfbd9ec7f6c5114e42935abfe))
* use unquoted heredoc in workflow to allow variable expansion ([079e3eb](https://github.com/retraut/gatekeeper/commit/079e3eb6bda8274c567d8c9062932dda7e57c697))
* wait for release artifacts before processing ([05e26a1](https://github.com/retraut/gatekeeper/commit/05e26a16e7422b23dd5431a8dd77fbb6f6b8bb9d))

## [0.4.2](https://github.com/retraut/gatekeeper/compare/v0.4.1...v0.4.2) (2025-12-30)


### Bug Fixes

* improve changelog documentation ([572f497](https://github.com/retraut/gatekeeper/commit/572f497859ad1dd3b602435609273c1f22270e06))

## [0.4.1](https://github.com/retraut/gatekeeper/compare/v0.4.0...v0.4.1) (2025-12-30)


### Bug Fixes

* add --repo option to gh pr merge for detached HEAD ([71af873](https://github.com/retraut/gatekeeper/commit/71af8734a559f1d0aa53dc9784733a6c29d95e53))
* add --skip-existing to gh release download ([06bc499](https://github.com/retraut/gatekeeper/commit/06bc49991d9ede496a0af330f0e0e35f3b909b5b))
* correct YAML heredoc delimiter in workflow ([42fb69f](https://github.com/retraut/gatekeeper/commit/42fb69fe681ef352cfefa8cf9034e0e82f8f3a31))
* specify base branch for create-pull-request action ([f04b6af](https://github.com/retraut/gatekeeper/commit/f04b6affe2679e13f5f17e5c7317a0738a221d3c))
* use pipe delimiter in sed for SHA256 substitution ([61bc1ba](https://github.com/retraut/gatekeeper/commit/61bc1babe58679a22d5cc0675f5d55e02052c626))
* use python instead of shell heredoc to avoid YAML parsing issues ([d426f3f](https://github.com/retraut/gatekeeper/commit/d426f3f39f54b61cfbd9ec7f6c5114e42935abfe))

## [0.4.0](https://github.com/retraut/gatekeeper/compare/v0.3.0...v0.4.0) (2025-12-30)


### Features

* auto-merge brew formula update PR on release ([9b4fd6d](https://github.com/retraut/gatekeeper/commit/9b4fd6def778e2cf6e7d36ca189662c05eff68dd))


### Bug Fixes

* don't auto-delete PID file - clean up only when daemon stops ([9bc8ec1](https://github.com/retraut/gatekeeper/commit/9bc8ec18e660a02ea840c4364b7c0337c9fb0dbe))
* handle already-stopped daemon gracefully in stop command ([2deba93](https://github.com/retraut/gatekeeper/commit/2deba930def4091091de4c4582035976ba3b3219))
* use proper heredoc with sed substitution for workflow variables ([79002f7](https://github.com/retraut/gatekeeper/commit/79002f7fd4af864586cf24f5cf0cc2dd83ffeac8))
* use unquoted heredoc in workflow to allow variable expansion ([079e3eb](https://github.com/retraut/gatekeeper/commit/079e3eb6bda8274c567d8c9062932dda7e57c697))
* wait for release artifacts before processing ([05e26a1](https://github.com/retraut/gatekeeper/commit/05e26a16e7422b23dd5431a8dd77fbb6f6b8bb9d))

## [0.3.0](https://github.com/retraut/gatekeeper/compare/v0.2.0...v0.3.0) (2025-12-30)


### Features

* add 'gatekeeper stop' command to gracefully stop daemon ([b57870c](https://github.com/retraut/gatekeeper/commit/b57870c56f4ff682a0e92cfeb24f01c843e05b24))
* add daemon status to state - show uptime, PID, and last check time ([1c5fa66](https://github.com/retraut/gatekeeper/commit/1c5fa66cebdb8e274d1189d94395ac862cae0314))


### Bug Fixes

* correct YAML indentation in release workflow ([f7bf2ba](https://github.com/retraut/gatekeeper/commit/f7bf2ba84694c2cd777fb46f070ff0abcf6a935a))
* remove unnecessary 'daemon' alias - use 'start' command only ([1c94ebd](https://github.com/retraut/gatekeeper/commit/1c94ebd7eb0b1561bcf844994572f68ae32add9a))
* simplify release workflow - remove complex homebrew update step ([215e842](https://github.com/retraut/gatekeeper/commit/215e8421ae70cc3f92e07768c0039e7797f68b92))
# Gatekeeper 0.4.2

- Improved workflow reliability
- Fixed Brew formula update automation
Fixed: workflow heredoc syntax and publish-release automation
fix: publish artifacts directly on release event
