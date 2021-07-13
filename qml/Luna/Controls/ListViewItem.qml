import QtQuick 2.15
import QtQuick.Templates 2.15 as Templates

import Luna.Styles 1.0 as Styles
import Luna.Utils 1.0 as Utils

Templates.ItemDelegate {
	id: _root
	implicitHeight: Styles.Hints.menuItemHeight
	width: ListView.view ? ListView.view.width : implicitWidth
	font: Styles.Fonts.primaryFont
	topPadding: 0
	bottomPadding: 0
	leftPadding: Styles.Hints.spacing / 2
	rightPadding: Styles.Hints.spacing / 2
	hoverEnabled: Styles.Hints.hoverEnabled
	spacing: Styles.Hints.spacing / 3
	highlighted: ListView.isCurrentItem

	onClicked: if (ListView.view) ListView.view.currentIndex = index

	indicator: Utils.SvgIcon {
		id: _icon
		x: _root.leftPadding
		icon: Styles.Icons.check
		color: Styles.Colors.getControlText(_root.enabled)
		anchors.verticalCenter: _root.verticalCenter
		enabled: false
		visible: _root.checkable && _root.checked
		opacity: _root.checkable && _root.checked ? 1 : 0
	}

	contentItem: Text {
		id: _text
		text: _root.text
		font: _root.font
		renderType: Text.NativeRendering
		height: parent.height
		color: Styles.Colors.getControlText(enabled)
		horizontalAlignment: Text.AlignLeft
		verticalAlignment: Text.AlignVCenter
		elide: Text.ElideRight
	}

	background: Rectangle {
		id: _background
		visible: _root.enabled && (_root.highlighted || _root.down || _root.hovered)
		color: Styles.Colors.getListItem(_root.highlighted, _root.hovered, _root.down)
		radius: Styles.Hints.radius - 2

		Behavior on color {
			enabled: _root.enabled
			ColorAnimation {
				duration: Styles.Hints.animationDuration / 2
				easing.type: Easing.OutCubic
			}
		}
	}
}
