import QtQuick 2.15

pragma Singleton

QtObject {
	id: _root

	readonly property Component	componentNumberAnimation: Component {
		NumberAnimation {
			onRunningChanged: {
				if (!running)
					destroy()
			}
		}
	}

	// Starts an animation that will be destroyed when finished.
	function startNumberAnimation(target, property, from, to, duration, easing) {
		const anim = _root.componentNumberAnimation.createObject(target, {
			"target": target,
			"running": false
		})
		anim.property = property
		anim.from = from
		anim.to = to
		anim.duration = duration ?? 150
		anim.easing.type = easing ?? Easing.InOutQuad
		anim.running = true
	}
}
