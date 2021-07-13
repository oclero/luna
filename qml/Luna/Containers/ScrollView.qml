import QtQuick 2.15 as QtQuick
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

import Luna.Styles 1.0 as Styles
import Luna.Controls 1.0 as Controls
import Luna.Utils 1.0 as Utils

// @disable-check M129
ScrollView {
	id: _root
	clip: true
	topPadding: 0
	bottomPadding: 0
	rightPadding: 0
	leftPadding: 0
	ScrollBar.horizontal.policy: ScrollBar.AsNeeded
	ScrollBar.vertical.policy: ScrollBar.AsNeeded
	ScrollBar.vertical.visible: false
	ScrollBar.horizontal.visible: false

	QtQuick.QtObject {
		id: _private
		property bool shouldShowScrollBar: false
		readonly property QtQuick.Flickable flickable: _root.contentItem
		readonly property QtQuick.Item focusItem: Utils.ScrollUtils.isParentOf(_root, _root.Window.activeFocusItem) ? _root.Window.activeFocusItem : null
		readonly property QtQuick.Component componentScrollBar: QtQuick.Component {
			Controls.ScrollBar {
				parent: _root
				anchors.right: orientation === Qt.Vertical ? _root.right : undefined
				anchors.top: orientation === Qt.Vertical ? _root.top : undefined
				anchors.left: orientation === Qt.Vertical ? undefined : _root.left
				anchors.bottom: _root.bottom
				height: orientation === Qt.Vertical ? _root.availableHeight : implicitHeight
				width: orientation === Qt.Horizontal ? _root.availableWidth : implicitWidth
				policy: orientation === Qt.Vertical ? _root.ScrollBar.vertical.policy : _root.ScrollBar.horizontal.policy
				needed: policy !== ScrollBar.AlwaysOff
								&& (_root.hovered || _private.flickable.moving || _private.shouldShowScrollBar)
								&& (orientation === Qt.Vertical ? _private.flickable.contentHeight > _root.availableHeight
																								: _private.flickable.contentWidth > _root.availableWidth)
			}
		}

		onFocusItemChanged: {
			if (!focusItem) return
			const willShow = Utils.ScrollUtils.ensureVisibleScrollArea(_root, _private.focusItem, Styles.Hints.scrollMargin, Styles.Hints.scrollMargin, true)
			 showTransientScrollBars(willShow)
		}

		function scrollWithKeyboardVertically(direction, autoRepeat, faster) {
			Utils.ScrollUtils.scrollWithKeyboard(_private.flickable, _root.ScrollBar.vertical, direction, true, autoRepeat, faster)
			showTransientScrollBars(true)
		}

		function scrollWithKeyboardHorizontally(direction, autoRepeat, faster) {
			Utils.ScrollUtils.scrollWithKeyboard(_private.flickable, _root.ScrollBar.horizontal, direction, true, autoRepeat, faster)
			showTransientScrollBars(true)
		}

		function showTransientScrollBars(show) {
			_timerHover.stop()
			shouldShowScrollBar = show
			if (show) {
				_timerHover.start()
			}
		}

		// I've tried to use QtQuick.Template's ScrollView but there is a crash
		// when clicking on a scrollbar, for an unknown reason. Hence the unusual
		// need for injecting new scrollbars. The previous ones are hidden then replaced.
		function injectScrollBars() {
			_root.ScrollBar.vertical = _private.componentScrollBar.createObject(_root, {
				"orientation": Qt.Vertical
			})
			_root.ScrollBar.horizontal = _private.componentScrollBar.createObject(_root, {
				"orientation": Qt.Horizontal
			})
		}
	}

	QtQuick.Timer {
		id: _timerHover
		interval: 2000
		repeat: false
		onTriggered: {
			_private.shouldShowScrollBar = false
		}
	}

	onHoveredChanged: {
		_private. showTransientScrollBars(true)
	}

	QtQuick.Component.onCompleted: {
		_private.injectScrollBars()
	}

	QtQuick.Keys.onUpPressed: {
		_private.scrollWithKeyboardVertically(Utils.ScrollUtils.ScrollDirection.Previous, event.isAutoRepeat)
	}

	QtQuick.Keys.onDownPressed: {
		_private.scrollWithKeyboardVertically(Utils.ScrollUtils.ScrollDirection.Next, event.isAutoRepeat)
	}

	QtQuick.Keys.onLeftPressed: {
		_private.scrollWithKeyboardHorizontally(Utils.ScrollUtils.ScrollDirection.Previous, event.isAutoRepeat)
	}

	QtQuick.Keys.onRightPressed: {
		_private.scrollWithKeyboardHorizontally(Utils.ScrollUtils.ScrollDirection.Next, event.isAutoRepeat)
	}

	QtQuick.Keys.onPressed: {
		switch (event.key) {
		case Qt.Key_PageUp:
			_private.scrollWithKeyboardVertically(Utils.ScrollUtils.ScrollDirection.Previous, event.isAutoRepeat, true)
			event.accepted = true
			break
		case Qt.Key_PageDown:
			_private.scrollWithKeyboardVertically(Utils.ScrollUtils.ScrollDirection.Next, event.isAutoRepeat, true)
			event.accepted = true
			break
		default:
			break
		}
	}
}
