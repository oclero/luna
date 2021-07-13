import QtQuick 2.15
import QtQuick.Layouts 1.15

import Luna.Controls 1.0 as Controls
import Luna.Templates 1.0 as T
import Luna.Styles 1.0 as Styles

T.Vector3dEditorTemplate {
	id: _root
	from: -999999999 // TODO Strangely, Number.MIN_VALUE doesn't work.
	to: 999999999 // Same with Number.MAX_VALUE
	stepSize: 1
	implicitWidth: _layout.implicitWidth
	implicitHeight: _layout.implicitHeight

	RowLayout {
		id: _layout
		anchors.fill: _root
		spacing: Styles.Hints.spacing / 2

		Controls.DoubleSpinBox {
			id: _xSpinBox;
			from: _root.from
			to: _root.to
			value: _root.x
			onValueModified: _root.modifyX(value)
			decimals: _root.decimals
			stepSize: _root.stepSize
			label: "X"
			Layout.preferredWidth: implicitWidth
			Layout.fillWidth: true
		}

		Controls.DoubleSpinBox {
			id: _ySpinBox;
			from: _root.from
			to: _root.to
			value: _root.y
			onValueModified: _root.modifyY(value)
			decimals: _root.decimals
			stepSize: _root.stepSize
			label: "Y"
			Layout.preferredWidth: implicitWidth
			Layout.fillWidth: true
		}

		Controls.DoubleSpinBox {
			id: _zSpinBox;
			from: _root.from
			to: _root.to
			value: _root.z
			onValueModified: _root.modifyZ(value)
			decimals: _root.decimals
			stepSize: _root.stepSize
			label: "Z"
			Layout.preferredWidth: implicitWidth
			Layout.fillWidth: true
		}
	}
}
