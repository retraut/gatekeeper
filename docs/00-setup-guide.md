# Гatekeeper - Інструкція Збірки 🏗️

## ⚡ Швидкий Старт (2 хвилини)

```bash
cd /Users/retraut/Documents/gatekeeper
./build.sh --cli --install
```

Готово! `gatekeeper` встановлений у `~/.local/bin/`

## 🔍 Що Сталося?

Script `build.sh` це зробив:

1. ✅ Перевірив Go встановлення
2. ✅ Завантажив залежності (YAML)
3. ✅ Білдив CLI бінарник (5.9MB)
4. ✅ Встановив у `~/.local/bin/gatekeeper`
5. ✅ Встановив tmux helper
6. ✅ Створив конфіг

## 📋 Білда опції

```bash
./build.sh                    # Усе (CLI + app)
./build.sh --cli              # Тільки CLI
./build.sh --cli --install    # CLI + встановити
./build.sh --clean            # Прибрати артефакти
./build.sh --help             # Показати помічь
```

## ✅ Перевір Встановлення

```bash
# Перевір де встановлений бінарник
which gatekeeper
# /Users/retraut/.local/bin/gatekeeper

# Перевір версію
gatekeeper --help

# Перевір що config створений
cat ~/.config/gatekeeper/config.yaml

# Перевір статус
gatekeeper status --compact
```

## 🎯 Наступні Кроки

### 1. Налаштуй Послуги

```bash
nano ~/.config/gatekeeper/config.yaml
```

Змінь на твої послуги:

```yaml
services:
  - name: AWS
    check_cmd: "aws sts get-caller-identity > /dev/null 2>&1"
  - name: GitHub
    check_cmd: "gh auth status > /dev/null 2>&1"

interval: 30
```

### 2. Запусти Daemon

```bash
gatekeeper daemon
```

### 3. Перевір Статус (в іншому терміналі)

```bash
gatekeeper status
gatekeeper status --compact
gatekeeper status --json
```

## 🐞 Проблеми?

### "Command not found: gatekeeper"
```bash
# Додай до PATH
export PATH="$HOME/.local/bin:$PATH"
# Або в ~/.zshrc:
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### "Build failed"
```bash
# Переклад залежностей
go mod download
./build.sh --cli
```

### Daemon не оновлює стан
```bash
# Перевір що він біжить
ps aux | grep gatekeeper

# Перевір логи
tail -f ~/.cache/gatekeeper/gatekeeper.log
```

## 📂 Файли depois Білда

```
~/.local/bin/gatekeeper          # Основний бінарник
~/.local/bin/gatekeeper-tmux     # Helper для tmux
~/.config/gatekeeper/config.yaml # Конфіг послуг
~/.cache/gatekeeper/state.json   # Поточний статус
~/.cache/gatekeeper/log          # Логи
```

## 🔗 tmux Інтеграція

Додай до `~/.tmux.conf`:

```
set -g status-right "#(~/.local/bin/gatekeeper-tmux)"
```

Потім:

```bash
tmux source-file ~/.tmux.conf
```

## 🍎 macOS App (Опціонально)

Для повної Xcode (не CLI Tools):

```bash
./build.sh --app
```

Потім юз app з GatekeeperApp/build/Release/Gatekeeper.app

## 📚 Детальніше

- Білда: [BUILD.md](BUILD.md)
- Налаштування: [SETUP.md](SETUP.md)
- Як це працює: [ARCHITECTURE.md](ARCHITECTURE.md)
- Команди: [QUICKSTART.txt](QUICKSTART.txt)

---

**Готово?** Запусти: `gatekeeper daemon`
