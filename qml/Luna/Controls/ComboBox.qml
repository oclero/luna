import QtQml 2.15
import QtQuick 2.15
import QtQuick.Templates 2.15 as Templates
import QtQuick.Controls 2.15 as QtControls
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.15

import Luna.Controls 1.0 as Controls
import Luna.Styles 1.0 as Styles
import Luna.Utils 1.0 as Utils

// @disable-check M129
Templates.ComboBox {
	id: _root
	font: Styles.Fonts.primaryFont
	implicitHeight: Styles.Hints.controlHeight
	implicitWidth: 120
	leftPadding: Styles.Hints.spacing
	rightPadding: Styles.Hints.spacing / 2
	focusPolicy: Qt.StrongFocus

	// @disable-check M301
	QtObject {
		property bool spaceDown: false
		id: _private
	}

	background: Item {
		id: _background
		anchors.fill: _root

		layer.enabled: _root.visible && _root.enabled
		layer.effect: DropShadow {
			visible: _root.enabled
			transparentBorder: true
			horizontalOffset: 0
			verticalOffset: _root.down ? 0 : Styles.Hints.borderWidth
			radius: _root.down ? Styles.Hints.borderWidth : Styles.Hints.borderWidth * 2
			samples: (radius * 2) + 1
			color: (!_root.checkable || _root.checkable
							&& _root.checked) ? Styles.Colors.shadowColor : Styles.Colors.shadowColorLighter
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
		Loader {
			anchors.fill: parent
			active: !_root.editable
			sourceComponent: Utils.ButtonShape {
				anchors.fill: parent
				role: Utils.ButtonShape.Role.Secondary
				hovered: _root.hovered
				down: _root.down
				enabled: _root.enabled
				shadowEnabled: false
			}
		}
		Loader {
			anchors.fill: parent
			active: _root.editable
			sourceComponent: Utils.InputShape {
				anchors.fill: parent
				hovered: _root.hovered
				down: _root.down
				enabled: _root.enabled
				shadowEnabled: false
				hasFocus: _root.activeFocus
			}
		}
	}

	indicator: Utils.ButtonShape {
		id: _indicator
		anchors.right: parent.right
		height: parent.height
		width: Styles.Hints.controlHeight
		role: Utils.ButtonShape.Role.Primary
		shadowEnabled: false
		hovered: _root.hovered
		down: _root.down

		Utils.SvgIcon {
			id: _indicatorIcon
			icon: Styles.Icons.combobox
			color: Styles.Colors.getControlText(_root.enabled)
			anchors.centerIn: parent
			width: Styles.Hints.iconSize
			height: Styles.Hints.iconSize
			Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
			visible: status != Image.Null
			opacity: _root.enabled ? 1 : 0.5
		}
	}

	contentItem: Item {
		anchors.fill: _root
		anchors.leftMargin: _root.leftPadding
		anchors.rightMargin: _root.rightPadding + _root.indicator.width
		anchors.topMargin: _root.topPadding
		anchors.bottomMargin: _root.bottomPadding

		Loader {
			anchors.fill: parent
			active: !_root.editable
			sourceComponent: Text {
				id: _contentItem
				anchors.fill: parent
				text: _root.displayText
				font: _root.font
				color: Styles.Colors.getControlText(_root.enabled)
				horizontalAlignment: Text.AlignLeft
				verticalAlignment: Text.AlignVCenter
				elide: Text.ElideRight
				renderType: Text.NativeRendering
				visible: text.length > 0
			}
		}

		Loader {
			anchors.fill: parent
			active: _root.editable
			sourceComponent: TextInput {
				anchors.fill: parent
				text: _root.editText
				font: _root.font
				color: Styles.Colors.getControlText(_root.enabled)
				horizontalAlignment: Text.AlignLeft
				verticalAlignment: Text.AlignVCenter
				renderType: Text.NativeRendering
				clip: true
				selectByMouse: true
				selectionColor: Styles.Colors.primaryColor
				selectedTextColor: Styles.Colors.bodyTextColor
				activeFocusOnPress: true
				persistentSelection: true
				onEnabledChanged: {
					if (!enabled) {
						deselect()
					}
				}
			}
		}
	}

	popup: Templates.Popup {
		x: 0
		y: 0
		closePolicy: QtControls.Popup.CloseOnPressOutside | QtControls.Popup.CloseOnEscape
		implicitWidth: Math.max(_root.width,
														contentWidth + leftPadding + rightPadding)
		implicitHeight: contentHeight + topPadding + bottomPadding
		leftPadding: Styles.Hints.spacing / 4
		rightPadding: Styles.Hints.spacing / 4
		topPadding: Styles.Hints.spacing / 4
		bottomPadding: Styles.Hints.spacing / 4
		leftMargin: Styles.Hints.spacing / 4
		rightMargin: Styles.Hints.spacing / 4
		transformOrigin: Item.Top

		onAboutToShow: {
			y = getYPosition()
		}

		function getYPosition() {
			if (currentIndex > -1 && _listView.count > 0) {
				const currentItem = _listView.itemAtIndex(currentIndex)
				if (currentItem) {
					return (_root.height - currentItem.height) / 2 - currentItem.y - topPadding
				}
			}
			return 0
		}

		background: Rectangle {
			id: _menuBackground
			implicitWidth: 160
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

		contentItem: ListView {
			id: _listView
			implicitHeight: contentHeight
			model: _root.delegateModel
			interactive: Window.window ? contentHeight > Window.window.height : false
			clip: true
			currentIndex: _root.currentIndex
			implicitWidth: Utils.GeometryUtils.getMinimumWidth(this, count,
																												 _root.width)
			spacing: 0
			highlightMoveDuration: 0
			highlight: null
			focus: true
			keyNavigationEnabled: true
			highlightFollowsCurrentItem: true
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
	}

	// Fix non-forwarded press event.
	Keys.onPressed: {
		event.accepted = false
		if ((event.key === Qt.Key_Space || event.key === Qt.Key_Return)
				&& !event.isAutoRepeat) {
			_private.spaceDown = true
		}
	}

	// Fix non-forwarded release event.
	Keys.onReleased: {
		event.accepted = false
		if ((event.key === Qt.Key_Space || event.key === Qt.Key_Return)
				&& !event.isAutoRepeat) {
			_private.spaceDown = false
		}
	}

	delegate: Controls.MenuItem {
		text: _root.textRole ? (Array.isArray(
															_root.model) ? modelData[_root.textRole] : model[_root.textRole]) : modelData
		highlighted: _root.highlightedIndex === index
		indicator: null
		arrow: null
		width: parent.width

		// Fix non-forwarded press/release event.
		Connections {
			enabled: _root.highlightedIndex === index
			target: _private
			function onSpaceDownChanged() {
				down = _private.spaceDown || pressed
			}
		}
	}

	Utils.FocusBorder {
		id: _focusBorder
		showFocus: (_root.visualFocus || _root.activeFocus) && !popup.opened
		animateBorder: !popup.opened
	}
}
