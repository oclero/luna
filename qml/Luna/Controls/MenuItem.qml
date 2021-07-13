import QtQuick 2.15
import QtQuick.Templates 2.15 as Templates
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import Luna.Styles 1.0 as Styles
import Luna.Utils 1.0 as Utils

// @disable-check M129
Templates.MenuItem {
	property string shortcut: action ? action.shortcut : ""

	id: _root
	implicitHeight: Styles.Hints.menuItemHeight
	implicitWidth: Math.ceil(leftPadding + implicitContentWidth + rightPadding
									 + (indicator ? indicator.width + spacing : 0)
									 + (arrow && arrow.visible ? arrow.width + spacing : 0))
	font: Styles.Fonts.primaryFont
	topPadding: 0
	bottomPadding: 0
	leftPadding: Styles.Hints.spacing / 2
	rightPadding: Styles.Hints.spacing / 2
	hoverEnabled: true
	spacing: Styles.Hints.spacing / 3

	onSubMenuChanged: {
		if (subMenu) {
			subMenu.overlap = Styles.Hints.spacing / 2
		}
	}

	arrow: Utils.SvgIcon {
		id: _arrow
		x: _root.width - _root.rightPadding - width
		icon: Styles.Icons.right
		color: Styles.Colors.getControlText(_root.enabled)
		anchors.verticalCenter: _root.verticalCenter
		enabled: false
		visible: _root.subMenu
		opacity: _root.subMenu ? 1 : 0
	}

	indicator: Utils.SvgIcon {
		x: _root.leftPadding
		icon: Styles.Icons.check
		color: Styles.Colors.getControlText(_root.enabled)
		anchors.verticalCenter: _root.verticalCenter
		enabled: false
		visible: _root.checkable && _root.checked
		opacity: _root.checkable && _root.checked ? 1 : 0
	}

	contentItem: RowLayout {
		id: _contentLayout
		anchors.left: undefined // _root.left
		anchors.right: undefined //_root.right
		anchors.margins: 0
		spacing: 16

		Text {
			id: _text
			text: _root.text
			font: _root.font
			renderType: Text.NativeRendering
			height: parent.height
			color: Styles.Colors.getControlText(enabled)
			horizontalAlignment: Text.AlignLeft
			verticalAlignment: Text.AlignVCenter
			elide: Text.ElideRight
			Layout.fillWidth: true
			Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
			Layout.leftMargin: _root.indicator ? _root.indicator.width + _root.spacing : 0
		}

		Text {
			id: _textShortcut
			visible: _root.shortcut.length > 0
			text: _root.shortcut
			font: _root.font
			renderType: Text.NativeRendering
			height: parent.height
			elide: Text.ElideRight
			horizontalAlignment: Text.AlignRight
			verticalAlignment: Text.AlignVCenter
			color: _root.down || _root.highlighted ? Styles.Colors.getControlText(enabled)
																						 : Styles.Colors.getControlText(false)
			Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
			Layout.minimumWidth: implicitWidth
		}
	}

	background: Rectangle {
		id: _background
		visible: _root.enabled && (_root.highlighted || _root.down)
		color: Styles.Colors.getMenuItem(_root.highlighted, _root.down)
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
