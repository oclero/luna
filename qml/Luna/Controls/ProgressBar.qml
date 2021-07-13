import QtQuick 2.15
import QtQuick.Templates 2.15 as Templates
import QtGraphicalEffects 1.15

import Luna.Styles 1.0 as Styles

// @disable-check M129
Templates.ProgressBar {
	id: _root
	value: 0.0
	implicitHeight: Styles.Hints.controlHeight / 2
	implicitWidth: Styles.Hints.sliderDefaultWidth

	background: Rectangle {
		id: _background
		height: Styles.Hints.radius
		width: _root.width
		anchors.verticalCenter: _root.verticalCenter
		color: Styles.Colors.getSliderGroove(_root.enabled, false)
		radius: height / 2
		implicitHeight: Styles.Hints.radius
		layer.enabled: _root.enabled
		layer.effect: InnerShadow {
			horizontalOffset: 0
			verticalOffset: Styles.Hints.borderWidth
			radius: Styles.Hints.borderWidth
			samples: (radius * 2) + 1
			color: Styles.Colors.shadowColorLighter
		}
	}

	contentItem: Item {
		id: _contentItem

		Rectangle {
			id: _content
			width: getValueWidth(_root.width, _root.visualPosition)
			implicitHeight: Styles.Hints.radius
			height: Styles.Hints.radius
			anchors.verticalCenter: parent.verticalCenter
			radius: height / 2
			color: Styles.Colors.getSliderGroove(_root.enabled, true)
			visible: width > Styles.Hints.radius
			Behavior on width {
				NumberAnimation {
					duration: Styles.Hints.animationDuration
					easing.type: Easing.OutQuad
				}
			}

			layer.enabled: _root.enabled
			layer.effect: DropShadow {
				transparentBorder: true
				horizontalOffset: 0
				verticalOffset: Styles.Hints.borderWidth
				radius: Styles.Hints.borderWidth
				samples: (radius * 2) + 1
				color: Styles.Colors.shadowColorLighter
			}

			function getValueWidth(totalWidth, ratio) {
				const v = totalWidth * ratio
				return v < Styles.Hints.radius ? 0 : v
			}
		}
	}
}
