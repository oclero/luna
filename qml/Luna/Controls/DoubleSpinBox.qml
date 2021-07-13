import QtQuick 2.15
import QtQuick.Controls 2.15

import Luna.Controls 1.0 as Controls
import Luna.QmlUtils 1.0 as QmlUtils
import Luna.Styles 1.0 as Styles
import Luna.Templates 1.0 as T
import Luna.Utils 1.0 as Utils

T.DoubleSpinBox {
	id: _root
	from: -999999999 // TODO Strangely, Number.MIN_VALUE doesn't work.
	to: 999999999 // Same with Number.MAX_VALUE
	stepSize: 1
	implicitHeight: _textField.implicitHeight
	implicitWidth: Styles.Hints.controlWidthSmall * 2
		+ (_label.visible ? _label.implicitWidth + Styles.Hints.spacing / 2 : 0)
		+ (_unit.visible ? _unit.implicitWidth + Styles.Hints.spacing / 2 : 0)

	Keys.onUpPressed: {
		// First, commit current modification, if any.
		_textField.editingFinished()
		_root.increase()
	}

	Keys.onDownPressed: {
		// First, commit current modification, if any.
		_textField.editingFinished()
		_root.decrease()
	}

	Controls.TextField {
		id: _textField
		focus: true
		anchors.fill: parent
		selectByMouse: activeFocus
		activeFocusOnPress: true
		validator: _root.validator
		text: _root.valueAsText
		onEditingFinished: _root.modifyValue(_root.valueFromText(text))
		onActiveFocusChanged: if (!activeFocus) _root.modifyValue(_root.valueFromText(text))
		horizontalAlignment: TextField.AlignHCenter
		leftPadding: (_root.label ? _label.implicitWidth : 0) + Styles.Hints.spacing / 2
		rightPadding: (_root.unit ? _unit.implicitWidth : 0 ) + Styles.Hints.spacing / 2
		inputMethodHints: Qt.ImhFormattedNumbersOnly

		Controls.Text {
			id: _label
			x: Styles.Hints.spacing / 2
			opacity: _root.enabled ? 1.0 : 0.5
			visible: _root.label
			text: _root.label
			enabled: false
			height: _textField.height
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignLeft
		}

		Controls.Text {
			id: _unit
			x: parent.width - width - Styles.Hints.spacing / 2
			opacity: _root.enabled ? 1.0 : 0.5
			visible: _root.unit
			text: _root.unit
			enabled: false
			height: _textField.height
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignRight
		}

		WheelHandler {
			enabled: _textField.activeFocus
			onWheel: function (event) {
				const stepCount = (event.angleDelta.y ?? -event.angleDelta.x) / 120;
				const increment = stepCount * _root.stepSize
				_root.modifyValue(_root.value + increment)
			}
		}
	}

	QtObject {
		id: _private
		property real valueAtStart: _root.value
	}

	QmlUtils.DragHandler {
		visible: !_textField.activeFocus
		enabled: visible
		anchors.fill: parent
		cursorShape: Qt.SizeVerCursor

		onStarted: _private.valueAtStart = _root.value
		onDragged: function(deltaX, deltaY) {
			// Add/remove integer count of steps (no half-steps) every 10 pixels.
			const increment = Math.round(deltaY / 10) * _root.stepSize
			_root.modifyValue(_private.valueAtStart + increment)
		}
		onCanceled: _root.modifyValue(_private.valueAtStart)
		onClicked: _textField.forceActiveFocus()
	}
}
