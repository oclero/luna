import QtQuick 2.15
import QtQuick.Templates 2.15 as Templates

import Luna.Styles 1.0 as Styles

Templates.ToolSeparator {
	property real space: Math.floor(Styles.Hints.spacing / 2)
	property real thickness: Styles.Hints.borderWidth
	property alias color: _line.color

	id: _root
	orientation: Qt.Horizontal
	implicitWidth: horizontal ? 0 : thickness + space
	implicitHeight: horizontal ? thickness + space : 0

	contentItem: Item {
		Rectangle {
			id: _line
			color: Styles.Colors.secondaryColorDisabled
			height: horizontal ? thickness : parent.height
			width: horizontal ? parent.width : thickness
			anchors.verticalCenter: parent.verticalCenter
			anchors.horizontalCenter: parent.horizontalCenter
		}
	}
}
