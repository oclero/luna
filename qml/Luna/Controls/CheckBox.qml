import QtQml 2.15
import QtQuick 2.15
import QtQuick.Templates 2.15 as Templates
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import Luna.Styles 1.0 as Styles
import Luna.Utils 1.0 as Utils

// @disable-check M129
Templates.CheckBox {
	id: _root
	font: Styles.Fonts.primaryFont
	spacing: Styles.Hints.spacing / 2
	height: implicitHeight
	width: implicitWidth
	implicitHeight: Styles.Hints.controlHeight
	implicitWidth: _indicator.implicitWidth + (text.length > 0 ? spacing + _text.implicitWidth : 0)
	bottomPadding: 0
	topPadding: 0
	leftPadding: 0
	rightPadding: 0
	hoverEnabled: Styles.Hints.hoverEnabled
	focusPolicy: Qt.TabFocus
	autoRepeat: false

	indicator: Utils.ButtonShape {
		id: _indicator
		implicitWidth: Math.floor(Styles.Hints.controlHeight - Styles.Hints.radius - 4)
		implicitHeight: implicitWidth
		x: _root.leftPadding
		y: (parent.height - height) / 2
		radius: Styles.Hints.radius - 2
		checkable: true
		checked: _root.checked
		hovered: _root.hovered
		down: _root.down
		enabled: _root.enabled
		role: _root.checked ? Utils.ButtonShape.Primary : Utils.ButtonShape.Secondary

		Utils.SvgIcon {
			id: _icon
			visible: _root.checked
			scale: _root.checked ? 1 : 0
			anchors.centerIn: parent
			icon: Styles.Icons.check
			color: Styles.Colors.getControlText(_root.enabled)
			width: Styles.Hints.iconSize
			height: Styles.Hints.iconSize
			Layout.alignment: Qt.AlignCenter

			Behavior on scale {
				enabled: _root.enabled
				NumberAnimation {
					duration: _root.checked ? Styles.Hints.animationDuration / 3
																	: Styles.Hints.animationDuration
					easing.type: Easing.OutQuart
				}
			}
		}

		Utils.FocusBorder {
			id: _focusBorder
			showFocus: _root.visualFocus
			radius: parent.radius
		}
	}

	contentItem: Text {
		id: _text
		anchors.fill: parent
		color: Styles.Colors.getControlText(_root.enabled)
		text: _root.text
		font: _root.font
		elide: Text.ElideRight
		horizontalAlignment: Text.AlignLeft
		verticalAlignment: Text.AlignVCenter
		renderType: Text.NativeRendering
		leftPadding: _root.indicator.width + _root.spacing
		//width: _root.width - _indicator.width
		visible: _root.text.length > 0
	}

	Keys.onPressed: function(event) {
		if (event.isAutoRepeat && event.key === Qt.Key_Space) {
			event.accepted = true
		}
	}

	Keys.onReleased: function (event) {
		if (event.isAutoRepeat && event.key === Qt.Key_Space) {
			event.accepted = true
		}
	}
}
