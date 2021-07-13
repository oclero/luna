import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Templates 2.15 as T
import QtGraphicalEffects 1.15

import Luna.Controls 1.0 as Controls
import Luna.Styles 1.0 as Styles
import Luna.Utils 1.0 as Utils

// This SpinBox should be avoided, and is kept for compatibility.
// Prefer Luna.Controls.IntegerSpinBox as a better choice.
// @disable-check M129
T.SpinBox {
	id: _root
	from: 0
	to: 10
	value: 0
	stepSize: 1
	font: Styles.Fonts.primaryFont
	editable: true
	implicitWidth: Styles.Hints.controlWidthSmall * 2 + Styles.Hints.controlHeight * 1.5
	implicitHeight: Styles.Hints.controlHeight
	inputMethodHints: Qt.ImhFormattedNumbersOnly
	validator: IntValidator {
		bottom: Math.min(_root.from, _root.to)
		top: Math.max(_root.from, _root.to)
		locale: _root.locale.name
	}
	wheelEnabled: true

	QtObject {
		id: _private

		function selectAllIfFocus() {
			Qt.callLater(()=> {
				if (_root.activeFocus)
					_textInput.selectAll()
			})
		}
	}

	Keys.onUpPressed: {
		event.accepted = true
		if (_root.value < _root.to) {
			_root.increase()
			_root.valueModified()
			_private.selectAllIfFocus()
		}
	}

	Keys.onDownPressed: {
		event.accepted = true
		if (_root.value > _root.from) {
			_root.decrease()
			_root.valueModified()
			_private.selectAllIfFocus()
		}
	}

	contentItem: TextInput {
		id: _textInput
		text: _root.textFromValue(_root.value, _root.locale)
		font: _root.font
		color: Styles.Colors.getControlText(enabled)
		selectByMouse: true
		selectionColor: Styles.Colors.primaryColor
		selectedTextColor: Styles.Colors.bodyTextColor
		horizontalAlignment: Qt.AlignHCenter
		verticalAlignment: Qt.AlignVCenter
		readOnly: !_root.editable
		validator: _root.validator
		inputMethodHints: _root.inputMethodHints
		renderType: TextInput.NativeRendering
		padding: 0
		activeFocusOnPress: true
		clip: true
		anchors.fill: _root
		anchors.leftMargin: Styles.Hints.controlWidthSmall
		anchors.rightMargin: Styles.Hints.controlWidthSmall
		persistentSelection: false
	}

	down.indicator: Controls.Button {
		x: _root.mirrored ? parent.width - width : 0
		z: 1
		height: parent.height
		implicitWidth: Styles.Hints.controlWidthSmall
		iconId: Styles.Icons.minus
		shadowEnabled: true
		focusPolicy: Qt.NoFocus
		autoRepeat: true
		role: Controls.Button.Role.Secondary
		onClicked: {
			_root.decrease()
			_root.valueModified()
			_private.selectAllIfFocus()
		}
		onDoubleClicked: {
			_root.decrease()
			_root.valueModified()
			_private.selectAllIfFocus()
		}
	}

	up.indicator: Controls.Button {
		x: _root.mirrored ? 0 : parent.width - width
		z: 1
		height: parent.height
		implicitWidth: Styles.Hints.controlWidthSmall
		iconId: Styles.Icons.plus
		shadowEnabled: true
		focusPolicy: Qt.NoFocus
		autoRepeat: true
		role: Controls.Button.Role.Secondary
		onClicked: {
			_root.increase()
			_root.valueModified()
			_private.selectAllIfFocus()
		}
		onDoubleClicked: {
			_root.increase()
			_root.valueModified()
			_private.selectAllIfFocus()
		}
	}

	background: Utils.InputShape {
		anchors.fill: _root
		anchors.leftMargin: Styles.Hints.radius
		anchors.rightMargin: Styles.Hints.radius
		down: _root.down
		hovered: _root.hovered
		hasFocus: _root.activeFocus
		radius: Styles.Hints.radius

		layer.enabled: _root.visible && _root.enabled
		layer.effect: DropShadow {
			visible: _root.enabled
			transparentBorder: true
			horizontalOffset: 0
			verticalOffset: Styles.Hints.borderWidth
			radius: Styles.Hints.borderWidth * 2
			samples: (radius * 2) + 1
			color: Styles.Colors.shadowColorLighter
		}
	}

	Utils.FocusBorder {
		id: _focusBorder
		showFocus: (_root.visualFocus || _root.activeFocus)
	}
}
