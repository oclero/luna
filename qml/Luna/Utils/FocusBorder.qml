import QtQuick 2.15
import QtQuick.Controls 2.15

import Luna.Styles 1.0 as Styles

Popup {
	property bool showFocus: false
	property double radius: Styles.Hints.radius
	property double borderWidth: Styles.Hints.focusBorderWidth
	property int leftGap: 0
	property int rightGap: 0
	property int topGap: 0
	property int bottomGap: 0
	property bool animateBorder: true

	id: _root
	x: -leftGap
	y: -topGap
	width: parent ? parent.width + leftGap + rightGap : 0
	height: parent ? parent.height + topGap + bottomGap : 0
	enabled: false
	closePolicy: Popup.NoAutoClose

	onShowFocusChanged: {
		if (showFocus) {
			open()
		} else {
			close()
		}
	}

	Connections {
		target: parent

		function onVisibleChanged() {
			if (parent.visible && showFocus) {
				open()
			} else {
				close()
			}
		}
	}

	background: Rectangle {
		id: _rect
		anchors.fill: parent
		anchors.margins: 0
		border.color: Styles.Colors.primaryColorLighter
		border.width: 0
		color: "transparent"
		enabled: false
		opacity: 0
		radius: _root.radius

		SequentialAnimation on border.color {
			id: _rectBorderColorAnimation
			loops: Animation.Infinite
			running: _root.showFocus && _root.animateBorder
			ColorAnimation {
				to: Qt.lighter(Styles.Colors.primaryColorLighter, 1.25)
				duration: Styles.Hints.animationDuration * 2
				easing.type: Easing.OutCubic
			}
			ColorAnimation {
				to: Styles.Colors.primaryColorLighter
				duration: Styles.Hints.animationDuration * 4
				easing.type: Easing.OutCubic
			}
		}
	}

	enter: Transition {
		ParallelAnimation {
			NumberAnimation {
				target: _rect
				property: "anchors.margins"
				from: -_root.borderWidth * 3
				to: -_root.borderWidth
				duration: Styles.Hints.animationDuration * 2
				easing.type: Easing.InOutBack
			}
			NumberAnimation {
				target: _rect
				property: "radius"
				from: _root.radius + _root.borderWidth * 3
				to: _root.radius + _root.borderWidth
				duration: Styles.Hints.animationDuration * 2
				easing.type: Easing.InOutBack
			}
			NumberAnimation {
				target: _rect
				property: "opacity"
				from: 0
				to: 1
				duration: Styles.Hints.animationDuration / 2
				easing.type: Easing.InCubic
			}
			NumberAnimation {
				target: _rect
				property: "border.width"
				from: 0
				to: _root.borderWidth
				duration: Styles.Hints.animationDuration
				easing.type: Easing.InCubic
			}
		}
	}

	exit: Transition {
		ParallelAnimation {
			NumberAnimation {
				target: _rect
				property: "anchors.margins"
				from: -_root.borderWidth
				to: 0
				duration: Styles.Hints.animationDuration
				easing.type: Easing.InCubic
			}
			NumberAnimation {
				target: _rect
				property: "radius"
				from: _root.radius + _root.borderWidth
				to: _root.radius
				duration: Styles.Hints.animationDuration
				easing.type: Easing.InCubic
			}
			NumberAnimation {
				target: _rect
				property: "opacity"
				from: 1
				to: 0
				duration: Styles.Hints.animationDuration
				easing.type: Easing.InCubic
			}
			NumberAnimation {
				target: _rect
				property: "border.width"
				from: _root.borderWidth
				to: 0
				duration: Styles.Hints.animationDuration
				easing.type: Easing.InCubic
			}
		}
	}
}
