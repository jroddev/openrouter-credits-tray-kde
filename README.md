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

### Using kpackagetool6

```bash
kpackagetool6 --type Plasma/Plasmoid --install package/
```

After installing, right-click your panel, choose **Add Widgets**, and search for "OpenRouter Credits Monitor".

## Configuration

1. Right-click the widget in your panel and select **Configure…**
2. Enter your OpenRouter management API key
3. Adjust the refresh interval, currency symbol, and decimal places as desired

You can get your API key from [openrouter.ai/settings/keys](https://openrouter.ai/settings/keys).

The API key is stored locally on your machine and is only sent to `openrouter.ai` to fetch your credit balance.

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
