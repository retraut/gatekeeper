# Changelog

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
