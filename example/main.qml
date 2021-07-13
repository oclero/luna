import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15
import Qt.labs.platform 1.1 as Platform

import Luna.Controls 1.0 as Controls
import Luna.Containers 1.0 as Containers
import Luna.Styles 1.0 as Styles
import Luna.Utils 1.0 as Utils

ApplicationWindow {
	id: _root
	width: 720
	height: 400
	minimumWidth: 300
	minimumHeight: 300
	visible: true
	color: Styles.Colors.windowColor

	Flow {
		x: 32
		y: 32
		width: _root.width - 64
		height: implicitHeight + 64
		spacing: 32

		move: Transition {
			NumberAnimation { properties: "x,y"; easing.type: Easing.InOutCubic; duration: 300 }
		}

		Controls.Button {
			id: _buttonSecondary
			text: "Secondary Button"
		}

		Controls.Button {
			id: _buttonPrimary
			text: "Primary Button"
			role: Controls.Button.Role.Primary
		}

		Controls.CheckBox {
			id: _checkBox
			text: "CheckBox"
		}

		Controls.ComboBox {
			id: _comboBox
			model: ListModel {
				ListElement { text: "Item 0" }
				ListElement { text: "Item 1" }
				ListElement { text: "Item 2" }
				ListElement { text: "Item 3" }
				ListElement { text: "Item 4" }
			}
		}

		Controls.Slider {
			id: _slider
			from: 0
			to: 100
			value: 50
		}

		Controls.ProgressBar {
			id: _progressBar
			from: _slider.from
			to: _slider.to
			value: _slider.value
		}

		Controls.TextField {
			id: _textField
			text: "TextField"
			placeholderText: "Write something here"
		}

		Controls.Switch {
			id: _switch
		}

		Controls.SpinBox {
			id: _spinBox
			from: -10
			to: 10
			value: $dummyQObject ? $dummyQObject.intValue : 0
			onValueModified: $dummyQObject.intValue = value
		}

		Controls.IntegerSpinBox {
			id: _integerSpinBox
			label: "X"
			unit: "cm"
			from: -10
			to: 10
			value: $dummyQObject ? $dummyQObject.intValue : 0
			onValueModified: $dummyQObject.intValue = value
		}

		Controls.DoubleSpinBox {
			id: _doubleSpinBox
			label: "X"
			unit: "cm"
			from: -10.0
			to: 10.0
			stepSize: 0.1
			decimals: 1
			value: $dummyQObject ? $dummyQObject.doubleValue : 0.0
			onValueModified: $dummyQObject.doubleValue = value
		}

		Containers.Expander {
			id: _expander
			width: 200

			headerDelegate: RowLayout {
				width: _expander.width
				height: 24
				Controls.TreeViewArrow {
					expanded: _expander.expanded
					hasChildren: true
					onClicked: _expander.expanded = !_expander.expanded
				}
				Controls.Text {
					text: "Expander"
					Layout.fillWidth: true
				}
			}

			contentDelegate: Rectangle {
				color: "white"
				border.width: 2
				border.color: "red"
				implicitHeight: 100
				height: 100
				implicitWidth: 100

				Controls.Text {
					anchors.bottom: parent.bottom
					anchors.bottomMargin: 4
					anchors.horizontalCenter: parent.horizontalCenter
					color: "black"
					text: "content"
				}
			}
		}

		Controls.ListView {
			id: _listView
			height: 110 // To showcase scrolling.
			width: 200
			showBackground: true
			model: ListModel {
				ListElement { text: "Item 0" }
				ListElement { text: "Item 1" }
				ListElement { text: "Item 2" }
				ListElement { text: "Item 3" }
				ListElement { text: "Item 4" }
				ListElement { text: "Item 5" }
				ListElement { text: "Item 6" }
				ListElement { text: "Item 7" }
				ListElement { text: "Item 8" }
				ListElement { text: "Item 9" }
			}
		}

		Rectangle {
			width: 50
			height: 50
			color: Styles.Colors.windowColorDarker

			Controls.Text {
				anchors.fill: parent
				wrapMode: Text.Wrap
				text: "Click to open Menu"
				verticalAlignment: Text.AlignVCenter
				horizontalAlignment: Text.AlignHCenter
				enabled: false
			}

			TapHandler { onTapped: _menu.opened ? _menu.close() : _menu.popup(eventPoint.position) }

			Controls.Menu {
				id: _menu

				Controls.MenuItem { text: "MenuItem 0" }
				Controls.MenuItem { text: "MenuItem 1"; checkable: true; checked: true }
				Controls.MenuSeparator { }
				Controls.Menu {
					title: "Sub-menu"
					Controls.MenuItem { text: "Sub MenuItem 0" }
					Controls.MenuItem { text: "Sub MenuItem 1" }
					Controls.MenuItem { text: "Sub MenuItem 3" }
					Controls.MenuItem { text: "Sub MenuItem 4" }
					Controls.MenuItem { text: "Sub MenuItem 5" }
				}
				Controls.MenuItem { text: "MenuItem 3"; enabled: false; checkable: true; checked: true }
			}
		}

		Utils.SvgImage {
			id: _svgImage
			source: "qrc:/app_icon.ico"
			width: Math.max(16, (_slider.value / 100) * 128)
		}

		Containers.ScrollView {
			id: _scrollView
			width: 100
			height: 90
			clip: true

			ColumnLayout {
				width: _scrollView.availableWidth - 16

				Repeater { model: 10; Controls.TextField { text: index; Layout.preferredWidth: 50 } }
			}
		}

		Controls.Vector3dEditor {
			id: _vector3dEditor
			from: -10.0
			to: 10.0
			stepSize: 0.1
			decimals: 1
			value: $dummyQObject ? $dummyQObject.vector3d : Qt.vector3d(0.0, 0.0, 0.0)
			onValueModified: $dummyQObject.vector3d = value
		}
	}
}
