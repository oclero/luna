import QtQuick 2.15
import QtQuick.Controls 2.15 as QtControls
import QtGraphicalEffects 1.15

import Luna.Styles 1.0 as Styles

QtControls.ToolTip {
	enum DisplayMode {
		Auto,
		Manual
	}

	property int gap: Styles.Hints.spacing * 0.375
	property Item target: parent
	property bool hideOnPress: true
	property bool showTooltip: false
	property int displayMode: Tooltip.DisplayMode.Auto

	QtObject {
		id: _private
		property double deltaY: 0
	}

	id: _root
	enabled: false
	font: Styles.Fonts.primaryFont
	margins: Styles.Hints.spacing
	delay: Styles.Hints.tooltipDelay
	timeout: -1
	x: target ? Math.round((target.width - implicitWidth) / 2) : 0
	y: target ? -implicitHeight - gap + _private.deltaY : 0
	z: 100
	onShowTooltipChanged: {
		if (showTooltip) {
			_root.open()
		} else {
			_root.close()
		}
	}

	contentItem: Text {
		id: _tooltipText
		text: _root.text
		font: _root.font
		color: Styles.Colors.secondaryColorLighter
		renderType: Text.NativeRendering
		leftPadding: Styles.Hints.spacing / 2
		rightPadding: Styles.Hints.spacing / 2
		topPadding: 0
		bottomPadding: 0
		verticalAlignment: Text.AlignVCenter
		horizontalAlignment: Text.AlignHCenter
		width: _root.width
		wrapMode: Text.Wrap
	}
	background: Rectangle {
		color: Styles.Colors.tooltipColor
		radius: Styles.Hints.radius
		border.width: Styles.Hints.borderWidth
		border.color: Styles.Colors.secondaryColorPressed
		layer.enabled: true
		layer.effect: DropShadow {
			transparentBorder: true
			horizontalOffset: 0
			verticalOffset: Styles.Hints.borderWidth * 4
			radius: Styles.Hints.borderWidth * 12
			samples: (radius * 2) + 1
			color: Styles.Colors.tooltipShadowColor
		}
	}

	enter: Transition {
		ParallelAnimation {
			NumberAnimation {
				target: _private
				property: "deltaY"
				from: gap
				to: 0.0
				duration: Styles.Hints.animationDuration * 2
				easing.type: Easing.InOutCubic
			}
			NumberAnimation {
				property: "opacity"
				from: 0.0
				to: 1.0
				duration: Styles.Hints.animationDuration * 2
				easing.type: Easing.InOutCubic
			}
		}
	}
	exit: Transition {
		NumberAnimation {
			property: "opacity"
			to: 0.0
			duration: Styles.Hints.animationDuration
			easing.type: Easing.InOutCubic
		}
	}

	Timer {
		id: _timer
		interval: _root.delay
		repeat: false

		onTriggered: {
			if (_root.displayMode !== Tooltip.DisplayMode.Auto) {
				return
			}

			if (_root.target.hovered && !_root.target.down && _root.text) {
				showTooltip = true
			}
		}
	}

	onClosed: {
		_timer.stop()
		if (showTooltip) {
			showTooltip = false
		}
	}
	onOpened: {
		if (!showTooltip) {
			showTooltip = true
		}
	}

	Connections {
		id: _targetConnections
		target: _root.target
		enabled: _root.displayMode === Tooltip.DisplayMode.Auto

		function onHoveredChanged() {
			if (_root.target.hovered && _root.text) {
				_timer.start()
			} else {
				showTooltip = false
			}
		}
		function onDownChanged() {
			if (_root.hideOnPress && _root.target.down) {
				showTooltip = false
				_root.close()
			}
		}
	}
}
