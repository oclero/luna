import QtQuick 2.15 as QtQuick
import QtQuick.Controls 2.15
import QtQuick.Templates 2.15 as T

import Luna.Utils 1.0 as Utils
import Luna.Styles 1.0 as Styles

pragma Singleton

QtQuick.QtObject {
	id: _root

	// Returns true if parent is a parent of child, false otherwise.
	function isParentOf(parent, child) {
		if (!parent || !child || parent === child) return false

		let p = child
		while (p)  {
			p = p.parent
			if (p === parent) return true
		}
		return false
	}

	// Returns the contentY value needed to ensure item is visible in flickable's viewport.
	function getContentXYForVisiblity(flickable, item, marginX, marginY) {
		if (!flickable || !(flickable instanceof QtQuick.Flickable))
			return Qt.point(0, 0)

		if (!isParentOf(flickable, item) || !item.visible)
			return Qt.point(flickable.contentX, flickable.contentY)

		const coordsInFlickable = item.mapToItem(flickable.contentItem, 0, 0)

		// Compute X.
		const itemLeft = coordsInFlickable.x - marginX
		const itemWidth = item.width + marginX * 2
		const itemRight = itemLeft + itemWidth
		const contentX = flickable.contentX
		let newContentX = contentX
		if (itemLeft < contentX || itemRight < contentX) {
			newContentX = Math.max(0, Math.min(itemLeft, flickable.contentWidth))
		} else if (itemLeft > contentX + flickable.width || itemRight > contentX + flickable.width) {
			newContentX = Math.max(0, Math.min(itemLeft - flickable.width + itemWidth, flickable.contentWidth - flickable.width))
		}

		// Compute Y.
		const itemTop = coordsInFlickable.y - marginY
		const itemHeight = item.height + marginY * 2
		const itemBottom = itemTop + itemHeight
		const contentY = flickable.contentY
		let newContentY = contentY
		if (itemTop < contentY || itemBottom < contentY) {
			newContentY = Math.max(0, Math.min(itemTop, flickable.contentHeight))
		} else if (itemTop > contentY + flickable.height || itemBottom > contentY + flickable.height) {
			newContentY = Math.max(0, Math.min(itemTop - flickable.height + itemHeight, flickable.contentHeight - flickable.height))
		}

		return Qt.point(newContentX, newContentY)
	}

	// Ensures the item is visible in the Flickable's viewport.
	function ensureVisibleFlickable(flickable, item, marginX, marginY) {
		if (!flickable || !(flickable instanceof QtQuick.Flickable) || !item) return

		const contentX = flickable.contentX
		const contentY = flickable.contentY
		const newContentXY = getContentXYForVisiblity(flickable, item, marginX, marginY)

		if (newContentXY.x !== contentX || newContentXY.y !== contentY) {
			Utils.BindingUtils.updateProperty(flickable, "contentX", newContentXY.x)
			Utils.BindingUtils.updateProperty(flickable, "contentY", newContentXY.y)
		}
	}

	// Starts a scroll from current position to target position (range [0;1]).
	function startScroll(scrollBar, targetPosition, animate) {
		targetPosition = Math.min(1.0 - scrollBar.size, Math.max(0.0, targetPosition))
		if (scrollBar.position === targetPosition) return

		if (animate) {
			Utils.AnimationUtils.startNumberAnimation(scrollBar, "position", scrollBar.position, targetPosition)
		} else {
			Utils.BindingUtils.updateProperty(scrollBar, "position", targetPosition)
		}
	}

	// Ensures the item is visible in the ScrollView's viewport.
	function ensureVisibleScrollArea(scrollView, item, marginX, marginY, animate) {
		if (!scrollView || !(scrollView instanceof ScrollView) || !item) return

		const flickable = scrollView.contentItem
		if (!flickable || !(flickable instanceof QtQuick.Flickable)) return

		const contentX = flickable.contentX
		const contentY = flickable.contentY
		const newContentXY = getContentXYForVisiblity(flickable, item, marginX, marginY)

		let scrolled = false
		if (newContentXY.x !== contentX) {
			const hScrollBar = scrollView.ScrollBar.horizontal
			if (hScrollBar && hScrollBar instanceof T.ScrollBar) {
				const newScrollBarPos = newContentXY.x / flickable.contentWidth
				startScroll(hScrollBar, newScrollBarPos, animate)
				scrolled = true
			}
		}
		if (newContentXY.y !== contentY) {
			const vScrollBar = scrollView.ScrollBar.vertical
			if (vScrollBar && vScrollBar instanceof T.ScrollBar) {
				const newScrollBarPos = newContentXY.y / flickable.contentHeight
				startScroll(vScrollBar, newScrollBarPos, animate)
				scrolled = true
			}
		}

		return scrolled
	}

	enum ScrollDirection {
		Previous,
		Next
	}

	// Scrolls up/down based on keyboard input.
	function scrollWithKeyboard(flickable, scrollBar, direction, animate, autoRepeat, faster) {
		const totalSize = scrollBar.orientation === Qt.Vertical ? flickable.contentHeight
																														: flickable.contentWidth
		const value = scrollBar.position * totalSize
		const step = autoRepeat ? Styles.Hints.scrollStepAutoRepeat : Styles.Hints.scrollStep
		const factor = faster ? 2 : 1
		const deltaScroll = step * factor
		const newValue = direction === ScrollUtils.ScrollDirection.Previous ? value - deltaScroll
																																				: value + deltaScroll
		const newPos = Math.min(1.0 - scrollBar.size, Math.max(0.0, newValue / totalSize))
		startScroll(scrollBar, newPos, animate)
	}
}
