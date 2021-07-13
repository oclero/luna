pragma Singleton

import QtQuick 2.15

QtObject {
	enum OS {
		Windows,
		MacOS,
		Unsupported
	}

	readonly property int os: getOS(Qt.platform.os)
	readonly property bool macOS: Qt.platform.os == "osx"
	readonly property bool windows: Qt.platform.os == "windows"

	function getOS(qtPlatformOS) {
		if (qtPlatformOS == "osx") {
			return Platform.OS.MacOS
		} else if (qtPlatformOS == "windows") {
			return Platform.OS.Windows
		} else {
			return Platform.OS.Unsupported
		}
	}
}
