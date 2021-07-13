import QtQuick 2.15
import QtQuick.Templates 2.15 as Templates
import QtQuick.Controls 2.15 as QtControls
import QtQuick.Window 2.15
import QtGraphicalEffects 1.15

import Luna.Controls 1.0 as Controls
import Luna.Styles 1.0 as Styles
import Luna.Utils 1.0 as Utils

// @disable-check M129
Templates.Menu {
	property real minimumWidth: 150

	id: _root
	dim: false
	closePolicy: QtControls.Popup.CloseOnPressOutside | QtControls.Popup.CloseOnEscape
	implicitWidth: Math.max(150, contentWidth + leftPadding + rightPadding)
	implicitHeight: contentHeight + topPadding + bottomPadding
	leftPadding: Styles.Hints.spacing / 4
	rightPadding: Styles.Hints.spacing / 4
	topPadding: Styles.Hints.spacing / 4
	bottomPadding: Styles.Hints.spacing / 4
	leftMargin: Styles.Hints.spacing / 4
	rightMargin: Styles.Hints.spacing / 4
	transformOrigin: Item.TopLeft

	background: Rectangle {
		id: _menuBackground
		radius: Styles.Hints.radius
		layer.enabled: true
		color: "transparent"
		clip: true

		layer.effect: DropShadow {
			id: _shadow
			transparentBorder: true
			horizontalOffset: 0
			verticalOffset: 4
			radius: 16
			samples: (radius * 2) + 1
			color: Styles.Colors.shadowColor
		}

		// Handle mouse over disabled items.
		MouseArea {
			anchors.fill: _menuBackground
			anchors.margins: Styles.Hints.spacing / 4
			hoverEnabled: true
			onPositionChanged: {
				if (_root.currentIndex != -1) {
					_root.currentIndex = -1
				}
			}
		}

		Rectangle {
			anchors.fill: parent
			color: Styles.Colors.menuColor
			border.color: Styles.Colors.menuBorderColor
			border.width: Styles.Hints.borderWidth
			radius: Styles.Hints.radius
		}
	}

	delegate: Controls.MenuItem {
		id: _menuItem
	}

	contentItem: ListView {
		implicitHeight: contentHeight
		model: _root.contentModel
		interactive: Window.window ? contentHeight > Window.window.height : false
		clip: true
		currentIndex: _root.currentIndex
		implicitWidth: Utils.GeometryUtils.getMinimumWidth(this, count,
																											 _root.minimumWidth)
		spacing: 0
		highlightMoveDuration: 0
		highlight: null
	}

	enter: Transition {
		ParallelAnimation {
			NumberAnimation {
				property: "scale"
				from: 0.75
				to: 1.0
				duration: Styles.Hints.animationDuration / 2
				easing.type: Easing.OutCubic
			}
			NumberAnimation {
				property: "opacity"
				from: 0.0
				to: 1.0
				duration: Styles.Hints.animationDuration
				easing.type: Easing.OutCubic
			}
		}
	}

	exit: Transition {
		NumberAnimation {
			property: "opacity"
			to: 0.0
			duration: Styles.Hints.animationDuration
			easing.type: Easing.InCubic
		}
	}

	function openAt(posX, posY) {
		_root.x = posX
		_root.y = posY
		_root.open()
	}
}
