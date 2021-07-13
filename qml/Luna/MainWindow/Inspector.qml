import QtQuick 2.15
import QtQuick.Layouts 1.15

import Luna.Containers 1.0 as Containers
import Luna.Controls 1.0 as Controls
import Luna.Styles 1.0 as Styles

Containers.Panel {
	id: _root
	implicitWidth: 300
	width: implicitWidth
	side: Containers.Panel.Side.Right

	contentItem: Containers.ScrollView {
		id: _scrollView
		anchors.fill: parent
		leftPadding: Styles.Hints.spacing
		topPadding: Styles.Hints.spacing
		rightPadding: Styles.Hints.spacing
		bottomPadding: Styles.Hints.spacing

		ColumnLayout {
			id: _layout
			width: _scrollView.availableWidth
			height: implicitHeight
			enabled: $inspectorController.enabled
			spacing: Styles.Hints.spacing

			ColumnLayout {
				spacing: Styles.Hints.spacing / 2
				Layout.fillWidth: true

				Controls.Text {
					text: "Name:"
					Layout.fillWidth: true
				}

				Controls.TextField {
					id: _nameTextField
					placeholderText: "Name"
					text: $inspectorController.name
					onTextChanged: $inspectorController.name = text
					Layout.fillWidth: true
				}
			}

			Controls.Separator { Layout.fillWidth: true }

			GridLayout {
				rowSpacing: Styles.Hints.spacing / 2
				columnSpacing: Styles.Hints.spacing / 2
				columns: 2
				rows: 3
				Layout.fillWidth: true

				Controls.Text {
					text: "Position:"
					Layout.row: 0
					Layout.column: 0
					verticalAlignment: Text.AlignVCenter
					Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
				}

				Controls.Vector3dEditor {
					id: _editorPosition
					Layout.row: 0
					Layout.column: 1
					value: $inspectorController.position
					onValueModified: $inspectorController.position = value
					Layout.fillWidth: true
				}

				Controls.Text {
					text: "Rotation:"
					Layout.row: 1
					Layout.column: 0
					verticalAlignment: Text.AlignVCenter
					Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
				}

				Controls.Vector3dEditor {
					id: _editorRotation
					Layout.row: 1
					Layout.column: 1
					value: $inspectorController.rotation
					onValueModified: $inspectorController.rotation = value
					Layout.fillWidth: true
				}

				Controls.Text {
					text: "Scale:"
					Layout.row: 2
					Layout.column: 0
					verticalAlignment: Text.AlignVCenter
					Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
				}

				Controls.Vector3dEditor {
					id: _editorScale
					Layout.row: 2
					Layout.column: 1
					value: $inspectorController.scale
					onValueModified: $inspectorController.scale = value
					Layout.fillWidth: true
				}
			}

			Controls.Separator { Layout.fillWidth: true }

			Controls.Text {
				text: "Mesh Filter:"
				Layout.fillWidth: true
			}

			Controls.ComboBox {
				id: _meshFilterComboBox
				textRole: "display"
				valueRole: "uid"
				model: $meshResourceProxyModel
				currentIndex: indexOfValue($inspectorController.meshFilter)
				onCurrentValueChanged: {
					if (currentValue)
						$inspectorController.meshFilter = currentValue;
				}
				Layout.fillWidth: true
			}

			Controls.Text {
				text: "Mesh Renderer:"
				Layout.fillWidth: true
			}

			Controls.SpinBox {
				value: $inspectorController.materialCount
				onValueModified: $inspectorController.materialCount = value;
				Layout.fillWidth: true
			}

			Controls.LayoutSpacer {	}
		}
	}
}
