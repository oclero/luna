pragma Singleton

import QtQuick 2.15

QtObject {
	id: _root

	function getMinimumWidth(listView, count, minWidth) {
		let maxWidth = minWidth
		for (var i = 0; i < count; i++) {
			const item = listView.itemAtIndex(i)
			if (item) {
				maxWidth = Math.max(maxWidth, item.implicitWidth)
			}
		}
		return maxWidth
	}
}
