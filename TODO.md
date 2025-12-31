# TODO / Future Features

## Maybe (Low Priority)

### macOS Native Apps

**Menu Bar App**
- Native SwiftUI status bar app
- Quick status overview
- Click to auth services
- Built with GatekeeperApp/

**Widgets**
- WidgetKit support
- Desktop widgets (Small, Medium, Large)
- Lock Screen widgets
- Live status updates

**Build:**
```bash
cd GatekeeperApp
xcodebuild -scheme Gatekeeper -configuration Release build
```

**Note:** Requires full Xcode (not just Command Line Tools)

---

## Ideas

- [ ] Bash completion support
- [ ] Fish completion support
- [ ] Config validation command (`gatekeeper validate`)
- [ ] Service groups in config
- [ ] Retry with exponential backoff
- [ ] Custom notification sounds
- [ ] Email/Slack alerts for critical services
- [ ] Multi-config support
- [ ] Import/export configs
