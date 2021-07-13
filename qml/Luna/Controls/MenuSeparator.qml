import QtQuick 2.15
import QtQuick.Templates 2.15 as Templates

import Luna.Styles 1.0 as Styles

// @disable-check M129
Templates.MenuSeparator {
	id: _root
	enabled: false
	implicitHeight: implicitContentHeight + Styles.Hints.spacing / 2

	contentItem: Item {
		implicitHeight: Styles.Hints.borderWidth
		Rectangle {
			color: Styles.Colors.secondaryColorDisabled
			height: Styles.Hints.borderWidth
			anchors.left: parent.left
			anchors.leftMargin: Styles.Hints.spacing / 3
			anchors.right: parent.right
			anchors.rightMargin: Styles.Hints.spacing / 3
			anchors.verticalCenter: parent.verticalCenter
		}
	}
}
