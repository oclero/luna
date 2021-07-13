import QtQuick 2.15
import QtQuick.Templates 2.15 as Templates

import Luna.Styles 1.0 as Styles

// @disable-check M129
Templates.BusyIndicator {
	property int thickness: Styles.Hints.borderWidth * 3
	property color color: Styles.Colors.primaryColorLighter

	id: _root
	implicitWidth: implicitContentWidth
	implicitHeight: implicitContentHeight

	contentItem: Item {
		id: _contentItem
		implicitWidth: Styles.Hints.controlHeight
		implicitHeight: implicitWidth
		opacity: _root.visible && _root.running ? 1.0 : 0.0

		Behavior on opacity {
			NumberAnimation {
				target: _contentItem
				property: "opacity"
				duration: 150
				easing.type: Easing.InOutQuad
			}
		}

		RotationAnimator {
			target: _contentItem
			running: _root.visible && _root.running
			from: 0
			to: 360
			loops: Animation.Infinite
			duration: 2500
			easing.type: Easing.InExpo
		}

		Repeater {
			id: _repeater
			model: 3

			Item {
				id: _circleWrapper
				width: parent.width
				height: parent.height

				function getEasingType(index) {
					switch (index) {
					case 0:
						return Easing.OutExpo
					case 1:
						return Easing.OutCubic
					case 2:
						return Easing.OutSine
					default:
						return Easing.OutExpo
					}
				}

				OpacityAnimator {
					target: _circleWrapper
					running: index > 0 && _root.visible && _root.running
					from: 1.0
					to: 0.0
					loops: Animation.Infinite
					duration: 2500
					easing.type: Easing.OutCubic
				}

				RotationAnimator {
					target: _circleWrapper
					running: _root.visible && _root.running
					from: 0
					to: 360
					loops: Animation.Infinite
					duration: 2500
					easing.type: getEasingType(index)
				}

				Rectangle {
					id: _circle
					x: _circleWrapper.width / 2 - width / 2
					y: _circleWrapper.height / 2 - height / 2
					implicitWidth: _root.thickness * 1.5
					implicitHeight: _root.thickness * 1.5
					radius: _root.thickness
					opacity: 1 - Math.pow(index / _repeater.count, 1 / 2)
					color: _root.color
					transform: [
						Translate {
							y: -Math.min(_circleWrapper.width,
													 _circleWrapper.height) * 0.5 + _root.thickness
						}
					]
				}
			}
		}
	}
}
