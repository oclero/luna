import Luna.Controls 1.0 as Controls
import Luna.Containers 1.0 as Containers
import QtQuick.Layouts 1.15

Containers.Panel {
	id: _root
	side: Containers.Panel.Side.Left
	implicitWidth: 300
	width: implicitWidth

	contentItem: ColumnLayout {
		Controls.TreeView {
			Layout.fillWidth: true
			Layout.preferredHeight: 300
			model: $sceneModel
			onCurrentModelIndexChanged: $inspectorController.entity = $sceneModel.data(currentModelIndex, 257)
		}
		Controls.ListView {
			Layout.fillWidth: true
			Layout.fillHeight: true
			model: $materialResourceProxyModel
		}
	}
}


