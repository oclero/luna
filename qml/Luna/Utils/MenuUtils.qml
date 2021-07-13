pragma Singleton

import QtQuick 2.15

QtObject {
	id: _root

	// Checks the right MenuItem according to currentData.
	// MenuItemGroup must be exclusive, and MenuItems must have a 'data' property.
	function updateCheckedMenuItem(menuItemGroup, currentData, dataOperation) {
		const items = menuItemGroup.items

		// Transform currentData if necessary.
		if (dataOperation && currentData) {
			currentData = dataOperation(currentData)
		}

		// Iterate over menu items.
		for (var i = 0; i < items.length; i++) {
			const item = items[i]

			// Transform item's data if necessary.
			let data = item.data
			if (dataOperation && data) {
				data = dataOperation(data)
			}

			// Check the menu item.
			// We don't need to iterate over all items since the group is mutually exclusive.
			if (data === currentData) {
				item.checked = true
				break
			}
		}
	}
}
