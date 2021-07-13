import QtQuick 2.15
import QtQuick.Layouts 1.15

import Luna.Styles 1.0 as Styles

Item {
	property bool expanded: false
	property bool cache: true
	property real spacing: 0
	property Component headerDelegate: null
	property Component contentDelegate: null
	readonly property Item headerItem: _headerLoader.item
	readonly property Item contentItem: _contentLoader.item
	property int animationDuration: Styles.Hints.animationDuration * 2
	readonly property alias expanding: _contentAnimation.running
	readonly property real availableHeight: _root.height - _headerLoader.height - _root.spacing

	id: _root
	implicitWidth: _layout.implicitWidth
	implicitHeight: _layout.implicitHeight

	onExpandedChanged: {
		_private.contentShouldBeVisible = true

		// Re-enable animation.
		_behavior.enabled = true

		if (_root.expanded && !_contentLoader.active) {
			// Load the content before showing it.
			_contentLoader.active = true
		}
	}

	QtObject {
		property bool contentShouldBeVisible: false
		id: _private
	}

	ColumnLayout {
		id: _layout
		spacing: 0
		anchors.left: _root.left
		anchors.right: _root.right
		anchors.top: _root.top

		// Header (always loaded).
		Loader {
			id: _headerLoader
			active: true
			Layout.fillWidth: true
			sourceComponent: _root.headerDelegate
			Layout.bottomMargin: _private.contentShouldBeVisible ? _root.spacing : 0
		}

		// Content (clipped).
		Item {
			id: _contentClipper
			clip: true
			visible: _private.contentShouldBeVisible
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.topMargin: 1
			Layout.preferredHeight: _root.expanded && _root.contentItem ? _root.contentItem.implicitHeight : 0

			Behavior on Layout.preferredHeight {
				id: _behavior
				enabled: false

				NumberAnimation {
					id: _contentAnimation
					duration: _root.animationDuration
					easing.type: Easing.OutQuart
					onRunningChanged: {
						if (!running) {
							// Prevent height animation now that it is visible.
							_behavior.enabled = false

							if (!_root.expanded) {
								_private.contentShouldBeVisible = false

								// Unload the content once it's hidden if cache is disabled.
								if (!cache) {
									_contentLoader.active = false
								}
							}
						}
					}
				}
			}

			// Load the content when necessary.
			Loader {
				id: _contentLoader
				active: false
				anchors.fill: parent
				sourceComponent: _root.contentDelegate
			}
		}
	}
}
