import QtQuick 2.15
import QtGraphicalEffects 1.15

import Luna.Utils 1.0 as Utils

Utils.SvgImage {
	property color color: "transparent"
	property alias icon: _root.source

	id: _root
	width: 16
	height: 16
	layer.enabled: _root.color != null && _root.color != "transparent"
	asynchronous: true
	layer.effect: ColorOverlay {
		id: _colorOverlay
		visible: _root.layer.enabled
		color: _root.color
		antialiasing: true
	}
}
