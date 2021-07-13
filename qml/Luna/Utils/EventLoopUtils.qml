import QtQuick 2.15

pragma Singleton

QtObject {
	id: _root

	// This should be a private member.
	// Unfortunately we can't nest Component within QtObject.
	readonly property Component timerComponent: Component {
		Timer {
			interval: 0
			repeat: false
		}
	}

	// QML equivalent of QTimer::singleShot(t).
	// With t=0, it schedules a task on next event loop.
	function schedule(interval, callback) {
		const timer = timerComponent.createObject(this, { "interval": interval });
		timer.triggered.connect(function() {
			if (callback) {
				callback();
			}
			timer.destroy();
		});
		timer.start();
	}
}
