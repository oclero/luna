import QtQuick 2.15 as QtQuick
import QtQuick.Templates 2.15 as Templates
import QtQuick.Controls 2.15 as QtControls

import Luna.Styles 1.0 as Styles
import Luna.Controls 1.0 as Controls

// @disable-check M129
QtQuick.ListView {
	property bool showBackground: false

	id: _root
	clip: true
	implicitWidth: Styles.Hints.controlDefaultWidth
	implicitHeight: count * Styles.Hints.menuItemHeight

	delegate: Controls.ListViewItem {
		id: _delegate
		text: model.display ?? model.text
	}

	QtQuick.Rectangle {
		id: _background
		visible: _root.showBackground
		z: -1
		anchors.fill: _root
		color: Styles.Colors.windowColorDarker
	}
}
