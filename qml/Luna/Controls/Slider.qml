import QtQml 2.15
import QtQuick 2.15
import QtQuick.Templates 2.15 as Templates
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import Luna.Styles 1.0 as Styles
import Luna.Utils 1.0 as Utils

// @disable-check M129
Templates.Slider {
	id: _root

	readonly property alias down: _root.pressed
	readonly property alias keyDown: _private.keyDown
	readonly property alias handleHovered: _private.handleHovered
	property string tooltip: Number(value).toFixed(2)

	// @disable-check M301
	QtObject {
		id: _private
		property bool keyDown: false
		property int handleSize: _root.pressed ? Styles.Hints.sliderHandleSize
																						 + 2 : Styles.Hints.sliderHandleSize
		property bool handleHovered: false
	}

	value: 0.0
	implicitWidth: Styles.Hints.sliderDefaultWidth
	leftPadding: 0
	rightPadding: 0
	topPadding: 0
	bottomPadding: 0
	implicitHeight: Styles.Hints.controlHeight

	Keys.onPressed: {
		event.accepted = false
		if (event.key === Qt.Key_Left || event.key === Qt.Key_Right) {
			_private.keyDown = true
		}
	}
	Keys.onReleased: {
		event.accepted = false
		if (event.key === Qt.Key_Left || event.key === Qt.Key_Right) {
			_private.keyDown = false
		}
	}
	onMoved: {
		_private.keyDown = false
	}
	onActiveFocusChanged: {
		if (!activeFocus) {
			_private.keyDown = false
		}
	}

	background: Item {
		id: _background
		x: 0
		y: (_root.height - height) / 2
		width: _root.width
		height: implicitHeight
		implicitHeight: Styles.Hints.radius

		Rectangle {
			id: _rectGroove
			anchors.fill: parent
			radius: height * 0.5
			color: Styles.Colors.getSliderGroove(_root.enabled, false)
			layer.enabled: visible && _root.enabled
			layer.effect: InnerShadow {
				horizontalOffset: 0
				verticalOffset: Styles.Hints.borderWidth
				radius: Styles.Hints.borderWidth
				samples: (radius * 2) + 1
				color: Styles.Colors.shadowColorLighter
			}
		}

		Rectangle {
			id: _rectValue
			width: Math.round(
							 _root.visualPosition * (_root.width - _private.handleSize) + _private.handleSize / 2)
			height: parent.height
			color: Styles.Colors.getSliderGroove(_root.enabled, true)
			radius: height * 0.5
			Behavior on width {
				enabled: _private.keyDown
				NumberAnimation {
					duration: Styles.Hints.animationDuration
					easing.type: Easing.OutCubic
				}
			}
		}
	}

	handle: Rectangle {
		id: _rectHandle
		x: Math.round(_root.visualPosition * (_root.width - width))
		y: (_root.height - height) / 2
		implicitWidth: _private.handleSize
		implicitHeight: implicitWidth
		radius: height * 0.5
		color: Styles.Colors.getSliderHandle(_root.hovered, _root.pressed,
																				 _root.enabled, true)
		border.width: 0
		Behavior on color {
			enabled: _root.enabled
			ColorAnimation {
				duration: Styles.Hints.animationDuration / 2
				easing.type: Easing.InOutCubic
			}
		}
		Behavior on x {
			enabled: _private.keyDown
			NumberAnimation {
				duration: 250
				easing.type: Easing.OutCubic
			}
		}

		layer.enabled: _root.visible && _root.enabled
		layer.effect: DropShadow {
			visible: _root.enabled
			transparentBorder: true
			horizontalOffset: 0
			verticalOffset: _root.pressed ? 0 : Styles.Hints.borderWidth
			radius: _root.pressed ? Styles.Hints.borderWidth : Styles.Hints.borderWidth * 4
			samples: (radius * 2) + 1
			color: Styles.Colors.shadowColor
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

		MouseArea {
			anchors.fill: parent
			propagateComposedEvents: true
			hoverEnabled: true
			preventStealing: false
			acceptedButtons: Qt.NoButton
			onEntered: {
				_private.handleHovered = true
			}
			onExited: {
				_private.handleHovered = false
			}
		}
	}

	Utils.FocusBorder {
		id: _focusBorder
		showFocus: _root.visualFocus
		leftGap: Styles.Hints.focusBorderWidth * 2
		rightGap: Styles.Hints.focusBorderWidth * 2
	}

	Utils.Tooltip {
		id: _tooltip
		text: _root.tooltip
		hideOnPress: false
		delay: 600
		displayMode: Utils.Tooltip.DisplayMode.Manual
		x: Math.round(
				 _root.visualPosition * (_root.width - _rectHandle.width) - (width - _rectHandle.width) / 2)
		gap: Styles.Hints.focusBorderWidth

		Behavior on x {
			enabled: _private.keyDown
			NumberAnimation {
				property: "x"
				duration: 250
				easing.type: Easing.OutCubic
			}
		}
	}

	onHoveredChanged: {
		if (_root.hovered || _root.pressed) {
			_tooltip.showTooltip = true
		} else {
			_tooltip.showTooltip = false
			_timer.stop()
		}
	}

	onKeyDownChanged: {
		if (_root.keyDown) {
			_tooltip.showTooltip = true
		} else {
			_timer.restart()
		}
	}

	Timer {
		id: _timer
		interval: Styles.Hints.tooltipDelay * 4
		repeat: false
		onTriggered: {
			if (_root.hovered || _root.pressed) {
				_tooltip.showTooltip = true
			} else {
				_tooltip.showTooltip = false
			}
		}
	}
}
