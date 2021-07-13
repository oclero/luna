import QtQuick 2.15
import QtQuick.Controls 2.15 as QtQuickControls
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3 as QtQuickDialogs
import QtQuick.Window 2.15

import Luna.Controls 1.0 as Controls
import Luna.Styles 1.0 as Styles
import Luna.Utils 1.0 as Utils

Window {
	id: _root
	title: qsTr("About %1").arg(Qt.application.displayName)
	modality: Utils.Platform.macOS ? Qt.NonModal : Qt.WindowModal
	visible: false
	color: Styles.Colors.windowColor
	maximumHeight : Math.max(200, _layout.implicitHeight)
	maximumWidth : Math.max(300, _layout.implicitWidth)
	minimumHeight : maximumHeight
	minimumWidth : maximumWidth

	ColumnLayout {
		id: _layout
		anchors.fill: parent
		anchors.margins: Styles.Hints.spacing * 3
		spacing: Styles.Hints.spacing
		focus: true

		Keys.onEscapePressed: {
			close()
		}

		Utils.SvgImage {
			source: "qrc:/luna/resources/images/app/app_icon.svg"
			Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
			Layout.preferredHeight: 64
		}

		Controls.Text {
			id: _textApplicationName
			text: Qt.application.displayName
			horizontalAlignment: Text.AlignHCenter
			Layout.alignment: Qt.AlignHCenter
		}

		Controls.Text {
			id: _textVersionNumber
			text: qsTr("Version %1").arg(Qt.application.version.length > 0 ? Qt.application.version : "???")
			horizontalAlignment: Text.AlignHCenter
			Layout.alignment: Qt.AlignHCenter
		}

		Controls.LayoutSpacer {}
	}
}
