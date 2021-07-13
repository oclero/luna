import QtQuick 2.15
import QtGraphicalEffects 1.15

import Luna.Styles 1.0 as Styles

Item {
	property bool down: false
	property bool hovered: false
	property bool hasFocus: false
	property int radius: Styles.Hints.radius
	property bool shadowEnabled: true

	id: _root

	Rectangle {
		id: _background
		anchors.fill: parent
		color: Styles.Colors.getControlBackground(_root.enabled)
		radius: _root.radius
		layer.enabled: _root.enabled && _root.shadowEnabled
		layer.effect: InnerShadow {
			visible: _root.shadowEnabled
			horizontalOffset: 0
			verticalOffset: Styles.Hints.borderWidth * 2
			radius: Styles.Hints.borderWidth
			samples: (radius * 2) + 1
			color: Styles.Colors.shadowColorLighter
		}
	}
	Rectangle {
		anchors.fill: parent
		border.width: 1
		border.color: _root.hasFocus ? Styles.Colors.primaryColor : Styles.Colors.getSecondary(
																		 _root.hovered, _root.down, _root.enabled)
		enabled: false
		color: "transparent"
		radius: _root.radius
		Behavior on border.color {
			enabled: _root.enabled
			ColorAnimation {
				duration: Styles.Hints.animationDuration
				easing.type: Easing.OutCubic
			}
		}
	}
}
