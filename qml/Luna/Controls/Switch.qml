import QtQuick 2.15
import QtQuick.Templates 2.15 as Templates
import QtGraphicalEffects 1.15

import Luna.Styles 1.0 as Styles
import Luna.Utils 1.0 as Utils

// @disable-check M129
Templates.Switch {
	id: _root
	text: ""
	font: Styles.Fonts.primaryFont
	implicitWidth: Styles.Hints.sliderHandleSize * 2 + spacing + Math.ceil(
									 contentItem.implicitWidth)
	implicitHeight: Styles.Hints.controlHeight
	spacing: Styles.Hints.spacing / 2
	autoRepeat: false
	hoverEnabled: Qt.styleHints.useHoverEffects

	indicator: Rectangle {
		id: _groove
		implicitWidth: Styles.Hints.sliderHandleSize * 2
		implicitHeight: Styles.Hints.sliderHandleSize - Styles.Hints.radius
		x: 0
		y: (parent.height - height) / 2
		radius: height / 2
		color: Styles.Colors.getSliderGroove(_root.enabled, false)
		layer.enabled: visible && _root.enabled
		layer.effect: InnerShadow {
			horizontalOffset: 0
			verticalOffset: Styles.Hints.borderWidth
			radius: Styles.Hints.borderWidth
			samples: (radius * 2) + 1
			color: Styles.Colors.shadowColorLighter
		}

		Rectangle {
			id: _rectValue
			width: checked ? parent.width : Styles.Hints.radius * 2
			height: parent.height
			color: Styles.Colors.getSliderGroove(_root.enabled, true)
			radius: height / 2
			Behavior on width {
				NumberAnimation {
					duration: Styles.Hints.animationDuration / 2
					easing.type: Easing.InOutQuad
				}
			}
			Behavior on color {
				enabled: _root.enabled
				ColorAnimation {
					duration: Styles.Hints.animationDuration / 2
					easing.type: Easing.InOutQuad
				}
			}
		}

		Utils.FocusBorder {
			id: _focusBorder
			leftGap: Styles.Hints.focusBorderWidth * 2
			rightGap: Styles.Hints.focusBorderWidth * 2 + _root.spacing + _root.contentItem.implicitWidth
			topGap: Styles.Hints.focusBorderWidth * 2
			bottomGap: Styles.Hints.focusBorderWidth * 2
			showFocus: _root.visualFocus
		}
	}

	contentItem: Item {
		implicitWidth: Math.max(_textOn.implicitWidth, _textOff.implicitWidth)
		anchors.top: _root.top
		anchors.bottom: _root.bottom
		anchors.left: _root.indicator.right
		anchors.leftMargin: _root.spacing

		Text {
			id: _textOn
			text: qsTr("On")
			font: _root.font
			anchors.fill: parent
			color: Styles.Colors.getControlText(_root.enabled)
			horizontalAlignment: Text.AlignLeft
			verticalAlignment: Text.AlignVCenter
			elide: Text.ElideRight
			visible: _root.checked
		}
		Text {
			id: _textOff
			text: qsTr("Off")
			font: _root.font
			anchors.fill: parent
			color: Styles.Colors.getControlText(_root.enabled)
			horizontalAlignment: Text.AlignLeft
			verticalAlignment: Text.AlignVCenter
			elide: Text.ElideRight
			visible: !_root.checked
			renderType: Text.NativeRendering
		}
	}

	Keys.onPressed: {
		if (event.isAutoRepeat && event.key === Qt.Key_Space) {
			event.accepted = true
		}
	}
	Keys.onReleased: {
		if (event.isAutoRepeat && event.key === Qt.Key_Space) {
			event.accepted = true
		}
	}

	onDownChanged: {
		// Disable/enable animation first.
		_xBehavior.enabled = !down
	}

	Rectangle {
		property int deltaPress: 2

		id: _handle
		x: _root.checked ? (_root.down ? parent.indicator.width - width + deltaPress
																		 / 2 : parent.indicator.width
																		 - width) : (_root.down ? -deltaPress / 2 : 0)
		y: (parent.height - height) / 2
		width: _root.down ? Styles.Hints.sliderHandleSize + deltaPress : Styles.Hints.sliderHandleSize
		height: width
		radius: height / 2
		color: Styles.Colors.getSliderHandle(_root.hovered, _root.down,
																				 _root.enabled, _root.checked)
		opacity: 1.0
		layer.enabled: _root.enabled
		layer.effect: DropShadow {
			visible: _root.enabled
			transparentBorder: true
			horizontalOffset: 0
			verticalOffset: Styles.Hints.borderWidth
			radius: Styles.Hints.borderWidth * 4
			samples: (radius * 2) + 1
			color: Styles.Colors.shadowColor
		}

		Behavior on x {
			id: _xBehavior
			NumberAnimation {
				duration: _root.Styles.Hints.animationDuration / 2
				easing.type: Easing.InOutQuad
			}
		}
		Behavior on color {
			enabled: _root.enabled
			ColorAnimation {
				duration: _root.Styles.Hints.animationDuration / 2
				easing.type: Easing.InOutQuad
			}
		}
	}
}
