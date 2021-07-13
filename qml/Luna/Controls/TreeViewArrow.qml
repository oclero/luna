import QtQuick 2.15

import Luna.Styles 1.0 as Styles
import Luna.Utils 1.0 as Utils

Item {
	signal clicked
	property color color: Styles.Colors.getControlText(enabled)
	property bool expanded: false
	property bool hasChildren: false

	id: _root
	implicitHeight: Styles.Hints.menuItemHeight
	implicitWidth: implicitHeight
	height: implicitHeight
	width: implicitWidth

	Utils.SvgIcon {
		id: _icon
		icon: _root.expanded ? Styles.Icons.down : Styles.Icons.right
		color: _root.color
		width: Styles.Hints.iconSize
		height: Styles.Hints.iconSize
		anchors.centerIn: parent
		visible: status != Image.Null && _root.hasChildren
	}

	TapHandler {
		enabled: _root.hasChildren
		onTapped: {
			if (_root.hasChildren)
				_root.clicked()
		}
	}
}
