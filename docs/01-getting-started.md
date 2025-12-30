# Gatekeeper - Start Here

## What Is Gatekeeper?

Gatekeeper monitors if your CLI tools (AWS, GitHub, Docker, etc.) are properly authenticated. Shows status in:
- **Menu bar** 🍎 (macOS app)
- **Desktop widgets** 🎨 (WidgetKit)
- **tmux status bar** 📡
- **HTTP endpoints** 🌐

All powered by a single daemon running in the background.

## ⚡ 5-Minute Quick Start

### 1. Build
```bash
cd /path/to/gatekeeper
./build.sh
```

This builds the CLI, installs it, and creates config.

### 2. Configure
```bash
nano ~/.config/gatekeeper/config.yaml
```

Add your services (AWS, GitHub, etc.)

### 3. Run
```bash
# Daemon automatically uses ~/.config/gatekeeper/config.yaml
gatekeeper daemon
```

In another terminal:
```bash
gatekeeper status --compact
```

(Or specify custom config path: `gatekeeper daemon --config /path/to/config.yaml`)

## 📖 Documentation

Pick a starting point based on what you need:

| I Want To... | Read This |
|---|---|
| Build everything | [BUILD.md](BUILD.md) |
| Understand the project | [SUMMARY.md](SUMMARY.md) |
| Get it running | [SETUP.md](SETUP.md) |
| Know how it works | [ARCHITECTURE.md](ARCHITECTURE.md) |
| See all commands | [QUICKSTART.txt](QUICKSTART.txt) |
| Find specific files | [INDEX.md](INDEX.md) |

## 🏗️ What's Included

### Phase 1: Skeleton & Configuration ✅
- Go CLI with YAML config
- Daemon loop checking services
- JSON state file

### Phase 2: Engine Enhancements ✅
- Concurrent service checks
- Per-service timeouts & retries
- Structured logging
- HTTP health endpoints

### Phase 3: tmux Integration ✅
- Helper script for tmux status bar
- One-command installation
- Auto-start support

### Phase 4: macOS GUI ✅
- MenuBar app (SwiftUI)
- WidgetKit (Desktop & Lock Screen)
- 3 widget sizes available

## 🎯 Build Options

**Everything (recommended):**
```bash
./build.sh
```

**Just CLI:**
```bash
./build.sh --cli
```

**CLI + install:**
```bash
./build.sh --cli --install
```

**Clean then rebuild:**
```bash
./build.sh --clean --cli
```

**macOS app:**
```bash
./build.sh --app
```

See: `./build.sh --help` or [BUILD.md](BUILD.md)

## 🚀 First Command

After building and configuring:

```bash
gatekeeper daemon
```

Then check status:
```bash
gatekeeper status --compact
```

Or add to tmux (edit `~/.tmux.conf`):
```
set -g status-right "#(~/.local/bin/gatekeeper-tmux)"
```

## 📂 Project Structure

```
gatekeeper/
├── build.sh               ← Start here to build
├── 00_START_HERE.md      ← This file
├── QUICKSTART.txt        ← Commands reference
├── BUILD.md              ← Detailed build guide
├── SUMMARY.md            ← Project overview
├── SETUP.md              ← Installation & config
├── ARCHITECTURE.md       ← How it works
├── INDEX.md              ← Documentation index
│
├── Go CLI (11 files)
│   ├── main.go
│   ├── daemon.go
│   ├── config.go
│   └── ... (more)
│
└── macOS App (GatekeeperApp/)
    ├── Gatekeeper.swift
    ├── GatekeeperWidget.swift
    └── GatekeeperApp.xcodeproj
```

## 💾 Installation Paths

After building, you'll have:

| File | Location | Purpose |
|------|----------|---------|
| Binary | `~/.local/bin/gatekeeper` | Main CLI |
| tmux helper | `~/.local/bin/gatekeeper-tmux` | For tmux status |
| Config | `~/.config/gatekeeper/config.yaml` | Service definitions |
| State | `~/.cache/gatekeeper/state.json` | Current status |
| Logs | `~/.cache/gatekeeper/gatekeeper.log` | Debug logs |

## 🐛 Troubleshooting

**Build fails?**
→ Check: `go version`, see [BUILD.md](BUILD.md)

**Can't find gatekeeper command?**
→ Run: `which gatekeeper` or check `~/.local/bin/`

**Daemon not updating state?**
→ Run: `ps aux | grep gatekeeper` to check if it's running

**Need more help?**
→ Check: [SETUP.md](SETUP.md) or [INDEX.md](INDEX.md)

## 🎓 Learning Path

**Beginner:** READ → BUILD → RUN
1. Read this file
2. Run `./build.sh`
3. Edit config
4. Start daemon
5. Check status

**Intermediate:** Customize
1. Add custom services to config
2. Integrate with tmux
3. Monitor with logs

**Advanced:** Extend
1. Read [ARCHITECTURE.md](ARCHITECTURE.md)
2. Build macOS app
3. Add webhooks
4. Customize widgets

## ✨ Key Features

- **Concurrent checks** - All services checked in parallel
- **Configurable timeouts** - Per-service timeout handling
- **Automatic retries** - Smart retry logic
- **Multiple UIs** - CLI, MenuBar, Widgets, tmux
- **JSON state** - Single source of truth
- **HTTP API** - For monitoring systems
- **Zero dependencies** - Only YAML parsing library

## 📞 Support Resources

1. **This file** - Quick overview
2. [QUICKSTART.txt](QUICKSTART.txt) - Command reference
3. [BUILD.md](BUILD.md) - How to build
4. [SETUP.md](SETUP.md) - Installation & config
5. [ARCHITECTURE.md](ARCHITECTURE.md) - How it works
6. [INDEX.md](INDEX.md) - Full navigation

## 🚀 Next Steps

1. **Build:**
   ```bash
   ./build.sh
   ```

2. **Configure:**
   ```bash
   nano ~/.config/gatekeeper/config.yaml
   ```

3. **Run:**
   ```bash
   gatekeeper daemon
   ```

4. **Check:**
   ```bash
   gatekeeper status
   ```

5. **Integrate (optional):**
   - Add to tmux
   - Build macOS app
   - Add widgets

---

**Ready?** Start with: `./build.sh`

**Questions?** Check: [INDEX.md](INDEX.md)

**Need details?** Read: [SETUP.md](SETUP.md)
