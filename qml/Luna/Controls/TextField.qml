import QtQml 2.15
import QtQuick 2.15
import QtQuick.Templates 2.15 as Templates
import QtQuick.Controls 2.15 as QtControls
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import Luna.Controls 1.0 as Controls
import Luna.Styles 1.0 as Styles
import Luna.Utils 1.0 as Utils

// @disable-check M129
Templates.TextField {
	property bool down: false
	property int radius: Styles.Hints.radius
	property alias iconId: _icon.icon

	id: _root
	renderType: Text.NativeRendering
	color: Styles.Colors.getControlText(_root.enabled)
	hoverEnabled: true
	selectByMouse: true
	selectionColor: Styles.Colors.primaryColor
	selectedTextColor: Styles.Colors.bodyTextColor
	font: Styles.Fonts.primaryFont
	leftPadding: _icon.visible ? Styles.Hints.iconSize
															 + Styles.Hints.spacing : Styles.Hints.spacing / 2
	rightPadding: Styles.Hints.spacing / 2
	placeholderTextColor: Styles.Colors.getControlPlaceholder(_root.enabled)
	activeFocusOnPress: true
	persistentSelection: _menu.visible
	implicitWidth: Styles.Hints.controlDefaultWidth
	implicitHeight: Styles.Hints.controlHeight
	verticalAlignment: TextInput.AlignVCenter

	onEnabledChanged: {
		if (!enabled) {
			deselect()
		}
	}
	onVisibleChanged: {
		deselect()
	}

	background: Utils.InputShape {
		id: _background
		down: _root.down
		hovered: _root.hovered
		enabled: _root.enabled
		hasFocus: _root.activeFocus
		radius: _root.radius
		Utils.SvgIcon {
			id: _icon
			anchors.verticalCenter: parent.verticalCenter
			x: Styles.Hints.spacing / 2
			color: Styles.Colors.getControlCaption(_root.enabled)
			width: Styles.Hints.iconSize
			height: Styles.Hints.iconSize
			visible: status != Image.Null
		}
		Text {
			id: _placeholder
			text: _root.placeholderText
			color: _root.placeholderTextColor
			renderType: _root.renderType
			font: _root.font
			enabled: false
			visible: _root.text.length <= 0
			anchors.fill: parent
			verticalAlignment: Text.AlignVCenter
			leftPadding: _root.leftPadding
			rightPadding: _root.rightPadding
			elide: Text.ElideRight
		}
	}

	Utils.FocusBorder {
		id: _focusBorder
		showFocus: _root.activeFocus || _menu.visible
		animateBorder: _root.activeFocus || !_menu.visible
	}

	onPressed: {
		if (event.button === Qt.LeftButton) {
			down = true
		}
		if (!activeFocus) {
			forceActiveFocus()
		}
	}
	onPressAndHold: {
		if (event.button === Qt.LeftButton && !activeFocus) {
			down = false
			forceActiveFocus()
		}
	}
	onReleased: {
		down = false
		if (event.button === Qt.RightButton) {
			_menu.popup(event.x, event.y)
		}
	}

	Controls.Menu {
		id: _menu
		QtControls.Action {
			id: _actionCopy
			text: qsTr("Copy")
			checkable: false
			enabled: _root.selectedText.length > 0
			shortcut: "Ctrl+C"
			onTriggered: {
				_root.forceActiveFocus()
				_root.copy()
			}
		}
		QtControls.Action {
			id: _actionPaste
			text: qsTr("Paste")
			enabled: _root.canPaste
			shortcut: "Ctrl+V"
			onTriggered: {
				_root.forceActiveFocus()
				_root.paste()
			}
		}
		QtControls.Action {
			id: _actionCut
			text: qsTr("Cut")
			enabled: _root.selectedText.length > 0
			shortcut: "Ctrl+X"
			onTriggered: {
				_root.forceActiveFocus()
				_root.cut()
			}
		}
		Controls.MenuSeparator {
			id: _menuSeparator
		}
		QtControls.Action {
			id: _actionSelectAll
			text: qsTr("Select All")
			enabled: _root.selectedText.length > 0
			shortcut: "Ctrl+A"
			onTriggered: {
				_root.forceActiveFocus()
				_root.selectAll()
			}
		}
	}
}
