import QtQuick.Layouts 1.15

import Luna.Containers 1.0 as Containers
import Luna.Controls 1.0 as Controls

Containers.Panel {
	// TODO Use a Controller for these properties
	property bool leftPanelVisible: false
	property bool rightPanelVisible: false

	id:  _root
	side: Containers.Panel.Side.Top
	padding: 8
	height: 40

	contentItem: RowLayout {
		spacing: 4

		Controls.CheckBox {
			checked: leftPanelVisible
			onCheckedChanged: leftPanelVisible = checked
			Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
		}

		Controls.LayoutSpacer { }

		Controls.CheckBox {
			checked: rightPanelVisible
			onCheckedChanged: rightPanelVisible = checked
			Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
		}
	}
}
