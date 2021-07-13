import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Templates 2.15 as T

import Luna.Styles 1.0 as Styles

// @disable-check M129
T.ScrollBar {
	property real thickness: Styles.Hints.scrollBarFullThickness
	property real thicknessSmall: Styles.Hints.scrollBarSmallThickness
	property bool needed: false

	id: _root
	padding: Styles.Hints.borderWidth
	implicitWidth: orientation === Qt.Vertical ? thickness : 100
	implicitHeight: orientation === Qt.Horizontal ? thickness : 100
	minimumSize: 0.2
	opacity: 0.0
	visible: false
	focusPolicy: Qt.NoFocus

	QtObject {
		property real actualThickness: _root.hovered || _root.pressed ? _root.thickness
																																	: _root.thicknessSmall
		id: _private
		Behavior on actualThickness { NumberAnimation { duration: Styles.Hints.animationDuration } }
	}

	contentItem: Item {
		id: _handle
		implicitHeight: _root.orientation === Qt.Horizontal ? _root.thickness : 100
		implicitWidth: _root.orientation === Qt.Vertical ? _root.thickness : 100

		Rectangle {
			x: _root.orientation === Qt.Vertical ? parent.width - width : 0
			y: _root.orientation === Qt.Horizontal ? parent.height - height : 0
			height: _root.orientation === Qt.Vertical ? parent.height : _private.actualThickness - _root.topPadding - _root.bottomPadding
			width: _root.orientation === Qt.Horizontal ?  parent.width : _private.actualThickness - _root.leftPadding - _root.rightPadding
			radius: _root.orientation === Qt.Vertical ? width / 2 : height / 2
			color: Styles.Colors.getScrollBarHandle(_hoverHandler.hovered, _root.pressed, enabled)

			Behavior on color { ColorAnimation { duration: Styles.Hints.animationDuration } }
		}

		HoverHandler { id: _hoverHandler }
	}

	background: Item {
		id: _groove
		anchors.fill: _root
		implicitHeight: _root.orientation === Qt.Horizontal ? _root.thickness : 100
		implicitWidth: _root.orientation === Qt.Vertical ? _root.thickness : 100

		Rectangle {
			x: _root.orientation === Qt.Vertical ? parent.width - width : 0
			y: _root.orientation === Qt.Horizontal ? parent.height - height : 0
			height: _root.orientation === Qt.Vertical ? parent.height : _private.actualThickness
			width:  _root.orientation === Qt.Horizontal ? parent.width : _private.actualThickness
			color: Styles.Colors.getScrollBarGroove(_root.hovered, _root.pressed, enabled)

			Behavior on color { ColorAnimation { duration: Styles.Hints.animationDuration } }
		}
	}

	states: [
		State {
			name: "stateNeeded"
			when: _root.needed
			PropertyChanges {
				target: _root
				opacity: 1.0
				visible: true
			}
		},
		State {
			name: "stateNotNeeded"
			when: !_root.needed
			PropertyChanges {
				target: _root
				opacity: 0.0
				visible: false
			}
		}
	]

	transitions: [
		Transition {
			to: "stateNeeded"
			SequentialAnimation {
				NumberAnimation {
					target: _root
					property: "visible"
					duration: 0
				}
				NumberAnimation {
					target: _root
					property: "opacity"
					duration: Styles.Hints.animationDuration * 2
					easing.type: Easing.OutCubic
				}
			}
		},
		Transition {
			to: "stateNotNeeded"
			SequentialAnimation {
				NumberAnimation {
					target: _root
					property: "opacity"
					duration: Styles.Hints.animationDuration * 2
					easing.type: Easing.OutCubic
				}
				NumberAnimation {
					target: _root
					property: "visible"
					duration: 0
				}
			}
		}
	]
}
