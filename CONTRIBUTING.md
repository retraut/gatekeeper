# Contributing to Gatekeeper

## Commit Message Format

This project uses **Conventional Commits** for automated versioning and changelog generation via [Release Please](https://github.com/googleapis/release-please-action).

### Format

```
<type>(<optional scope>): <description>

<optional body>

<optional footer>
```

### Types

- **`feat:`** - A new feature (triggers minor version bump)
- **`fix:`** - A bug fix (triggers patch version bump)
- **`docs:`** - Documentation changes only
- **`style:`** - Code style changes (formatting, missing semicolons, etc.)
- **`refactor:`** - Code refactoring without feature/fix changes
- **`perf:`** - Performance improvements
- **`test:`** - Adding or updating tests
- **`chore:`** - Build, dependency, or tooling changes

### Breaking Changes

To indicate a breaking change, add `!` after the type:

```
feat!: Redesigned config format

BREAKING CHANGE: The config file format has changed from YAML v2 to v3
```

This triggers a **major version bump**.

### Examples

**New feature:**
```
feat(config): Add support for environment variables in auth_cmd

Users can now use $VAR syntax to reference environment variables
in authentication commands.
```

**Bug fix:**
```
fix(daemon): Fix race condition in concurrent service checks

When checking multiple services in parallel, a mutex was not
properly protecting the state update.
```

**Documentation:**
```
docs: Add examples for tmux integration
```

**Breaking change:**
```
feat!: Change default health_port from 8080 to 9090

BREAKING CHANGE: Services using the default health port must be updated
```

## Making a Release

1. Commits following **Conventional Commits** are pushed to `main`
2. **Release Please** automatically creates a Release PR with:
   - Updated version number (based on commit types)
   - Generated CHANGELOG.md
   - All artifacts listed
3. Review and merge the Release PR
4. Release Please automatically:
   - Creates a GitHub Release with the tag
   - Triggers the build workflow to compile and upload artifacts
5. Artifacts are published and available for download

## Development Workflow

1. Create feature branch: `git checkout -b feature/my-feature`
2. Make changes and commit with conventional format
3. Push and create pull request
4. CI checks run (build, test)
5. After approval, merge to `main`
6. Release Please handles the rest

## Code Style

- Follow Go best practices
- Run `go fmt` before committing
- Keep functions small and focused
- Add tests for new functionality
- Document public functions and exported types

## Building Locally

```bash
# Build for current platform
go build -o gatekeeper

# Build for specific platform
GOOS=linux GOARCH=amd64 go build -o gatekeeper-linux-amd64

# Run tests
go test -v ./...

# Build and test
./build.sh
```
