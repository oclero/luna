import QtQuick 2.15
import QtQuick.Controls 2.15

import Luna.Styles 1.0 as Styles

Pane {
	enum Side {
		Left,
		Top,
		Right,
		Bottom
	}

	property int side: Panel.Side.Left
	property alias color: _background.color
	property alias borderColor: _backgroundBorder.color

	id: _root
	implicitHeight: contentItem ? contentItem.implicitHeight : 0
	implicitWidth: contentItem ? contentItem.implicitWidth : 0

	x: _root.side === Panel.Side.Right ? parent.width - width : 0
	y: _root.side === Panel.Side.Bottom ? parent.height - height : 0

	background: Rectangle {
		id: _background
		color: Styles.Colors.windowColor

		Rectangle {
			id: _backgroundBorder
			width: _root.side === Panel.Side.Left || _root.side === Panel.Side.Right ? 1 : parent.width
			height: _root.side === Panel.Side.Top || _root.side === Panel.Side.Bottom ? 1 : parent.height
			x: _root.side === Panel.Side.Left ? parent.width - 1 : 0
			y: _root.side === Panel.Side.Top ? parent.height - 1 : 0
			color: Styles.Colors.windowBorderColor
		}
	}
}
