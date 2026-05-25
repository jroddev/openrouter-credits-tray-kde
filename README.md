# OpenRouter Credits Monitor

A KDE Plasma 6 system tray widget that displays your remaining [OpenRouter](https://openrouter.ai) credit balance directly in your panel.

![Screenshot](screenshot.png)
*Screenshot coming soon*

## Features

- Shows your remaining OpenRouter credit balance in the system tray
- Click to expand a detailed view with total credits, usage, and remaining balance
- Configurable auto-refresh interval (30 seconds to 1 hour)
- Customizable currency symbol and decimal places
- Manual "Refresh Now" button in the expanded view
- Hover tooltip with balance and last-updated timestamp
- Color-coded warnings for errors and negative balances

## Requirements

- **KDE Plasma 6.0** or later

## Installation

### Using the install script (recommended)

```bash
./install.sh
```

To upgrade an existing installation:

```bash
./install.sh --upgrade
```

The script uses `kpackagetool6` and will prompt you to restart plasmashell afterward.

### Manual

Copy the `package/` directory into your local Plasma plasmoids folder:

```bash
cp -r package ~/.local/share/plasma/plasmoids/com.openrouter.credits-monitor/
```

Then restart Plasma:

```bash
killall plasmashell
```

Or log out and back in.

After installing, right-click your panel, choose **Add Widgets**, and search for "OpenRouter Credits Monitor".

## Configuration

1. Right-click the widget in your panel and select **Configure…**
2. Enter your OpenRouter management API key
3. Adjust the refresh interval, currency symbol, and decimal places as desired

You can get your API key from [openrouter.ai/settings/keys](https://openrouter.ai/settings/keys).

### API Key Storage

Your API key is stored in **plaintext** in KDE's standard Plasma config file:

```
~/.config/plasma-org.kde.plasma.desktop-appletsrc
```

This is the standard KDE Plasma configuration mechanism (KConfig XT). The same file stores settings for all Plasma widgets on your system — it's not something we invented.

The key is only sent to `openrouter.ai` over HTTPS to fetch your credit balance. It is never sent anywhere else.

The configuration UI masks the key with a password field by default (with a show/hide toggle), so it won't be visible on screen during normal use.

If you're concerned about plaintext storage, consider:

- **File-level encryption** — e.g., LUKS full-disk or home directory encryption
- **Restricting file permissions** — `chmod 600 ~/.config/plasma-org.kde.plasma.desktop-appletsrc`

If you'd like to improve how the key is stored (e.g., integrating with KWallet or a system keyring), contributions are welcome.

## Usage

- **Compact view** — The panel shows your remaining balance (e.g. `$16.27`). A warning icon appears if there's an error.
- **Expanded view** — Click the widget to see total credits, total usage, remaining balance, and the last refresh time.
- **Refresh** — Click the "Refresh Now" button in the expanded view, or wait for the auto-refresh timer.
- **Tooltip** — Hover over the widget for a quick summary.

## Development

### Testing without installing

Run the widget in a standalone window:

```bash
plasmawindowed com.openrouter.credits-monitor
```

### Reloading after changes

Changes to QML files require restarting the Plasma shell:

```bash
killall plasmashell
```

Or simply log out and back in.

## Project Structure

```
.
├── install.sh                     # Install/upgrade script
├── package/
│   ├── metadata.json              # Plugin metadata (ID, name, version, license)
│   └── contents/
│       ├── config/
│       │   ├── config.qml         # Configuration page model
│       │   └── main.xml           # KConfig schema (apiKey, updateInterval, etc.)
│       └── ui/
│           ├── main.qml           # Main widget (compact + full representation)
│           └── configGeneral.qml  # Configuration UI
└── README.md
```

## License

MIT
