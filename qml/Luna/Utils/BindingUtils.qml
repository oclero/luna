import QtQuick 2.15

pragma Singleton

QtObject {
	id: _root

	readonly property Component	componentBinding: Component { Binding {} }

	// Updates the property without breaking existing bindings.
	function updateProperty(target, property, value) {
		const binding = _root.componentBinding.createObject(target, {
			"target": target,
			"property": property,
			"value": value,
			"restoreMode": Binding.RestoreBindingOrValue
		})
		binding.destroy()
	}
}
