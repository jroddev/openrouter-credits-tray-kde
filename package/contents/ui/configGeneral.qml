/*
 * configGeneral.qml — Configuration page for OpenRouter Credits Monitor
 *
 * This page appears when the user right-clicks the plasmoid and selects
 * "Configure…".  It uses KCM.SimpleKCM as the root item, which is the
 * standard Plasma 6 pattern for configuration pages.
 *
 * All fields are two-way bound to plasmoid.configuration.<key> so that
 * changes are saved automatically when the user clicks OK.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root

    // Track whether the API key password is currently visible
    property bool apiKeyVisible: false

    Kirigami.FormLayout {
        Layout.fillWidth: true

        // ── API Key ───────────────────────────────────────────────────
        Label {
            Kirigami.FormData.label: ""
            Layout.fillWidth: true
            text: "API Configuration"
            font.bold: true
            font.pixelSize: Kirigami.Units.fontPixelSize + 1
        }

        RowLayout {
            Kirigami.FormData.label: "OpenRouter API Key"
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            TextField {
                id: apiKeyField
                Layout.fillWidth: true
                placeholderText: "Enter your management API key"
                echoMode: root.apiKeyVisible ? TextInput.Normal : TextInput.Password
                text: plasmoid.configuration.apiKey
                onTextChanged: plasmoid.configuration.apiKey = text
            }

            Button {
                icon.name: root.apiKeyVisible ? "eye-off" : "eye"
                display: AbstractButton.IconOnly
                onClicked: root.apiKeyVisible = !root.apiKeyVisible
                ToolTip.text: root.apiKeyVisible ? "Hide API key" : "Show API key"
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        // ── Update Interval ───────────────────────────────────────────
        Label {
            Kirigami.FormData.label: ""
            Layout.fillWidth: true
            text: "Update Settings"
            font.bold: true
            font.pixelSize: Kirigami.Units.fontPixelSize + 1
        }

        RowLayout {
            Kirigami.FormData.label: "Update Interval"
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            SpinBox {
                id: intervalSpinBox
                from: 30
                to: 3600
                stepSize: 30
                value: plasmoid.configuration.updateInterval
                onValueChanged: plasmoid.configuration.updateInterval = value
            }

            Label {
                text: "(" + Math.round(intervalSpinBox.value / 60) + " minutes)"
                opacity: 0.7
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        // ── Display Settings ──────────────────────────────────────────
        Label {
            Kirigami.FormData.label: ""
            Layout.fillWidth: true
            text: "Display Settings"
            font.bold: true
            font.pixelSize: Kirigami.Units.fontPixelSize + 1
        }

        TextField {
            Kirigami.FormData.label: "Currency Symbol"
            Layout.fillWidth: true
            maximumLength: 3
            text: plasmoid.configuration.currencySymbol
            onTextChanged: plasmoid.configuration.currencySymbol = text
        }

        SpinBox {
            Kirigami.FormData.label: "Decimal Places"
            from: 0
            to: 4
            stepSize: 1
            value: plasmoid.configuration.decimalPlaces
            onValueChanged: plasmoid.configuration.decimalPlaces = value
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        // ── Help / Info ───────────────────────────────────────────────
        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            textFormat: Text.RichText
            text: {
                "<p style='margin-top:0;'>" +
                "Get your OpenRouter management API key from " +
                "<a href='https://openrouter.ai/settings/keys'>openrouter.ai/settings/keys</a>.</p>" +
                "<p style='margin-bottom:0;'>" +
                "The API key is stored locally on your machine and is only sent to " +
                "openrouter.ai to fetch your credit balance.</p>"
            }
            onLinkActivated: Qt.openUrlExternally(link)
            opacity: 0.7
            font: Kirigami.Theme.smallFont
        }
    }
}
