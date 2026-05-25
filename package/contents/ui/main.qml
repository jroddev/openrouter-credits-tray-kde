/*
 * main.qml — OpenRouter Credits Monitor Plasmoid
 *
 * Plasma 6 API:
 *   - Root element: PlasmoidItem (required in Plasma 6)
 *   - compactRepresentation: direct property of PlasmoidItem
 *   - fullRepresentation: direct property of PlasmoidItem
 *   - Plasmoid (attached property): configuration, icon, title, status, etc.
 *
 * Architecture:
 *   - CompactRepresentation:  A small label shown in the KDE panel
 *     displaying the remaining credit balance (e.g. "$16.27").
 *   - FullRepresentation:     A popup column shown when the user clicks
 *     the compact label, with detailed credit info and a refresh button.
 *   - Data fetching:          XMLHttpRequest calls the OpenRouter credits
 *     API on a timer and on demand.
 *   - Configuration:          Read from Plasmoid.configuration.* and
 *     reacts to changes via the configurationChanged signal.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras

PlasmoidItem {
    id: root

    // Size hints for plasmawindowed (so the window doesn't collapse to 0x0)
    // Only apply in Planar (windowed) mode — in panel mode these would
    // override the compact representation's Layout hints.
    Layout.minimumWidth: Plasmoid.formFactor === PlasmaCore.Types.Planar
        ? Kirigami.Units.gridUnit * 18 : 0
    Layout.minimumHeight: Plasmoid.formFactor === PlasmaCore.Types.Planar
        ? Kirigami.Units.gridUnit * 16 : 0
    switchWidth: Kirigami.Units.gridUnit * 10
    switchHeight: Kirigami.Units.gridUnit * 10

    // ── State properties ──────────────────────────────────────────────
    property double balance: 0
    property double totalCredits: 0
    property double totalUsage: 0
    property string lastUpdated: ""
    property bool isLoading: false
    property string errorMessage: ""

    // ── Configuration shortcuts (bound to Plasmoid.configuration) ────
    // These are readonly bindings — they update automatically when the
    // underlying config value changes, but do NOT emit onXChanged signals.
    // We use Plasmoid.configurationChanged to detect config updates.
    readonly property string apiKey: Plasmoid.configuration.apiKey
    readonly property int updateIntervalSec: Plasmoid.configuration.updateInterval
    readonly property string currencySymbol: Plasmoid.configuration.currencySymbol
    readonly property int decimalPlaces: Plasmoid.configuration.decimalPlaces

    // Track previous API key to detect changes via configurationChanged
    property string _prevApiKey: ""

    // ── Formatters ────────────────────────────────────────────────────
    // Format a number with the configured currency symbol and decimal places
    function formatCredits(value) {
        if (isNaN(value) || value === undefined) {
            return "--"
        }
        return currencySymbol + value.toFixed(decimalPlaces)
    }

    // Human-readable timestamp
    function formatTimestamp(dateStr) {
        if (!dateStr || dateStr === "") {
            return "Never"
        }
        var d = new Date(dateStr)
        return d.toLocaleString()
    }

    // ── API Fetch ─────────────────────────────────────────────────────
    function fetchCredits() {
        // Guard: don't fetch without an API key
        if (!apiKey || apiKey.length === 0) {
            errorMessage = "No API key configured"
            isLoading = false
            return
        }

        // Guard: don't start another request while one is in flight
        if (isLoading) {
            return
        }

        isLoading = true
        errorMessage = ""

        var xhr = new XMLHttpRequest()
        xhr.open("GET", "https://openrouter.ai/api/v1/credits")
        xhr.setRequestHeader("Authorization", "Bearer " + apiKey)

        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE) {
                return
            }

            isLoading = false

            // Handle HTTP-level errors
            if (xhr.status === 0) {
                errorMessage = "Network error — check your connection"
                return
            }

            if (xhr.status === 401 || xhr.status === 403) {
                errorMessage = "Authentication failed — check your API key"
                return
            }

            if (xhr.status !== 200) {
                errorMessage = "API error (HTTP " + xhr.status + ")"
                return
            }

            // Parse JSON response
            try {
                var response = JSON.parse(xhr.responseText)
                var data = response.data

                if (!data || data.total_credits === undefined || data.total_usage === undefined) {
                    errorMessage = "Unexpected API response format"
                    return
                }

                totalCredits = data.total_credits
                totalUsage = data.total_usage
                balance = data.total_credits - data.total_usage
                lastUpdated = new Date().toISOString()
                errorMessage = ""

            } catch (e) {
                errorMessage = "Failed to parse API response"
            }
        }

        xhr.send()
    }

    // ── Timer: periodic refresh ───────────────────────────────────────
    // The interval is bound to the config value. When the config changes,
    // the binding updates the timer's interval automatically.
    Timer {
        id: refreshTimer
        interval: root.updateIntervalSec * 1000   // convert seconds → ms
        running: true
        repeat: true

        onTriggered: fetchCredits()
    }

    // ── Trigger initial fetch on load (if API key is set) ─────────────
    Component.onCompleted: {
        // Remember the initial API key
        root._prevApiKey = root.apiKey

        if (root.apiKey && root.apiKey.length > 0) {
            fetchCredits()
        }
    }

    // ── React to configuration changes ────────────────────────────────
    // Plasmoid.configurationChanged fires whenever any config value changes.
    // We check specifically for API key changes here.
    Connections {
        target: Plasmoid
        function onConfigurationChanged() {
            // Detect API key changes
            if (root.apiKey !== root._prevApiKey) {
                root._prevApiKey = root.apiKey
                if (root.apiKey && root.apiKey.length > 0) {
                    fetchCredits()
                } else {
                    errorMessage = "No API key configured"
                    balance = 0
                    totalCredits = 0
                    totalUsage = 0
                }
            }
        }
    }

    // ── Compact Representation (shown in the panel) ───────────────────
    compactRepresentation: Item {
        // Use Layout properties — the shell forces anchors.fill, so
        // the `width` property is ignored. The panel containment reads
        // Layout hints to decide how much space to allocate.
        Layout.preferredWidth: compactLabel.implicitWidth + Kirigami.Units.smallSpacing * 2
        Layout.minimumWidth: compactLabel.implicitWidth + Kirigami.Units.smallSpacing * 2
        Layout.maximumWidth: compactLabel.implicitWidth + Kirigami.Units.smallSpacing * 4
        Layout.minimumHeight: 0

        PlasmaComponents3.Label {
            id: compactLabel
            anchors.centerIn: parent
            text: {
                if (root.errorMessage !== "") {
                    return "⚠"
                }
                if (root.isLoading && root.lastUpdated === "") {
                    return "--"
                }
                return root.formatCredits(root.balance)
            }
            font: Kirigami.Theme.smallFont
            color: {
                if (root.errorMessage !== "") {
                    return Kirigami.Theme.negativeTextColor
                }
                return Kirigami.Theme.textColor
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.expanded = !root.expanded
            cursorShape: Qt.PointingHandCursor
        }
    }

    // ── Full Representation (popup details) ───────────────────────────
    fullRepresentation: ColumnLayout {
        id: fullView
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.smallSpacing

        // Title
        PlasmaComponents3.Label {
            Layout.fillWidth: true
            text: "OpenRouter Credits"
            font.bold: true
            font.pixelSize: Kirigami.Units.fontPixelSize + 2
            elide: Text.ElideRight
        }

        // Divider
        Kirigami.Separator {
            Layout.fillWidth: true
        }

        // Total Credits
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.largeSpacing

            PlasmaComponents3.Label {
                text: "Total Credits:"
                opacity: 0.7
            }

            PlasmaComponents3.Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                text: root.formatCredits(root.totalCredits)
            }
        }

        // Total Usage
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.largeSpacing

            PlasmaComponents3.Label {
                text: "Total Usage:"
                opacity: 0.7
            }

            PlasmaComponents3.Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                text: root.formatCredits(root.totalUsage)
            }
        }

        // Divider
        Kirigami.Separator {
            Layout.fillWidth: true
        }

        // Remaining Balance (prominent)
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.largeSpacing

            PlasmaComponents3.Label {
                text: "Remaining:"
                font.bold: true
            }

            PlasmaComponents3.Label {
                id: balanceLabel
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                text: root.formatCredits(root.balance)
                font.bold: true
                font.pixelSize: Kirigami.Units.fontPixelSize + 4
                color: {
                    if (root.balance < 0) {
                        return Kirigami.Theme.negativeTextColor
                    }
                    return Kirigami.Theme.textColor
                }
            }
        }

        // Last updated
        PlasmaComponents3.Label {
            Layout.fillWidth: true
            text: "Last updated: " + root.formatTimestamp(root.lastUpdated)
            opacity: 0.6
            font: Kirigami.Theme.smallFont
        }

        // Error / status message
        PlasmaComponents3.Label {
            Layout.fillWidth: true
            text: root.errorMessage
            color: Kirigami.Theme.negativeTextColor
            visible: root.errorMessage !== ""
            wrapMode: Text.WordWrap
            font: Kirigami.Theme.smallFont
        }

        // Loading indicator
        PlasmaComponents3.BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            running: root.isLoading
            visible: root.isLoading
        }

        // Refresh button
        PlasmaComponents3.Button {
            Layout.alignment: Qt.AlignHCenter
            text: "Refresh Now"
            icon.name: "view-refresh"
            onClicked: fetchCredits()
        }
    }
}
