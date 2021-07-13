import QtQuick 2.15
import Qt.labs.platform 1.1 as Platform
import QtQml.Models 2.15

import Luna.Utils 1.0 as Utils

// TODO This component should bind its MenuItems to corresponding Actions.

// @disable-check M129
Platform.MenuBar {
	// TODO Replace this with an Action.
	signal aboutClicked()

	id: _root

	Platform.Menu {
		title: qsTr("\&File")

		Platform.MenuItem {
			text: qsTr("\&New…")
			shortcut: "Ctrl+N"
			onTriggered: $engineController.clear()
		}

		Platform.MenuItem {
			text: qsTr("\&Import…")
			shortcut: "Ctrl+I"
			onTriggered: $engineController.import()
		}

		Platform.MenuItem {
			text: qsTr("\&Open…")
			shortcut: "Ctrl+O"
			onTriggered: $engineController.open()
		}

		Platform.MenuSeparator { }

		Platform.MenuItem {
			text: qsTr("\&Save…")
			shortcut: "Ctrl+S"
			onTriggered: $engineController.save()
		}

		Platform.MenuSeparator { }

		Platform.MenuItem {
			text: qsTr("\&Preferences")
			shortcut: "Ctrl+,"
			role: Platform.MenuItem.PreferencesRole
			enabled: false
		}

		Platform.MenuSeparator { }

		Platform.MenuItem {
			text: qsTr("\&Quit")
			shortcut: "Alt+F4"
			role: Platform.MenuItem.QuitRole
			onTriggered: Qt.quit()
		}
	}
	Platform.Menu {
		title: qsTr("\&Scene")

		Platform.MenuItem {
			text: qsTr("\&Create Object")
			shortcut: "Ctrl+Shift+O"
			onTriggered: $sceneController.create("Object", $inspectorController.entity)
		}
	}
	Platform.Menu {
		title: qsTr("\&View")

		Platform.Menu {
			id: _languageMenu
			title: qsTr("\&Language")

			Platform.MenuItem {
				text: qsTr("No available languages")
				enabled: false
				visible: $translationManager && $translationManager.rowCount === 0
			}

			Platform.MenuItemGroup {
				id: _languageGroup
			}

			Connections {
				target: $translationManager

				function onCurrentTranslationChanged() {
					_languageMenu.updateCheckMenuItem()
				}
			}

			Component.onCompleted: {
				_languageMenu.updateCheckMenuItem()
			}

			function updateCheckMenuItem() {
				Utils.MenuUtils.updateCheckedMenuItem(_languageGroup, $translationManager.currentTranslation)
			}

			Instantiator {
				model: $translationManager
				onObjectAdded: _languageMenu.insertItem(index, object)
				onObjectRemoved: _languageMenu.removeItem(object)

				Platform.MenuItem {
					property var data: model.translation
					checkable: true
					text: model.display
					group: _languageGroup
					onTriggered: {
						$translationManager.currentTranslation = data
					}
				}
			}
		}
	}
	Platform.Menu {
		title: qsTr("\&Help")

		Platform.MenuItem {
			text: qsTr("About...")
			role: Platform.MenuItem.AboutRole
			onTriggered: _root.aboutClicked()
		}
	}
}
