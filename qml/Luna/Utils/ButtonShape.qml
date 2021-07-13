import QtQuick 2.15
import QtGraphicalEffects 1.15

import Luna.Styles 1.0 as Styles

Item {
	enum Role {
		Primary,
		Secondary
	}

	property int radius: Styles.Hints.radius
	property int role: ButtonShape.Role.Primary
	property bool down: false
	property bool hovered: false
	property bool checkable: false
	property bool checked: false
	property bool shadowEnabled: true

	id: _root
	implicitHeight: Styles.Hints.controlHeight

	layer.enabled: _root.visible && _root.enabled && _root.shadowEnabled
	layer.effect: DropShadow {
		visible: _root.enabled && _root.shadowEnabled
		transparentBorder: true
		horizontalOffset: 0
		verticalOffset: _root.down ? 0 : Styles.Hints.borderWidth
		radius: _root.down ? Styles.Hints.borderWidth : Styles.Hints.borderWidth * 2
		samples: (radius * 2) + 1
		color: (!_root.checkable || _root.checkable && _root.checked) ? Styles.Colors.shadowColor
																																	: Styles.Colors.shadowColorLighter
		Behavior on verticalOffset {
			enabled: _root.enabled
			NumberAnimation {
				duration: Styles.Hints.animationDuration
				easing.type: Easing.OutCubic
			}
		}
		Behavior on radius {
			enabled: _root.enabled
			NumberAnimation {
				duration: Styles.Hints.animationDuration
				easing.type: Easing.OutCubic
			}
		}
	}

	Rectangle {
		id: _highlight
		anchors.fill: parent
		anchors.bottomMargin: parent.height / 2
		z: -1
		radius: _root.radius
		color: _root.role === ButtonShape.Role.Primary ? Styles.Colors.getPrimaryHighlight(_root.hovered,
																																											 _root.down,
																																											 _root.enabled)
																									 : Styles.Colors.getSecondaryHighlight(_root.hovered,
																																												 _root.down,
																																												 _root.enabled)
		Behavior on color {
			enabled: _root.enabled
			ColorAnimation {
				duration: Styles.Hints.animationDuration
				easing.type: Easing.OutCubic
			}
		}
	}

	Rectangle {
		id: _fill
		anchors.fill: parent
		anchors.topMargin: Styles.Hints.borderWidth
		radius: _root.radius
		color: _root.role === ButtonShape.Role.Primary ? Styles.Colors.getPrimary(_root.hovered,
																																							_root.down,
																																							_root.enabled)
																									 : Styles.Colors.getSecondary(_root.hovered,
																																								_root.down,
																																								_root.enabled)
		Behavior on color {
			enabled: _root.enabled
			ColorAnimation {
				duration: Styles.Hints.animationDuration
				easing.type: Easing.OutCubic
			}
		}
	}
}
