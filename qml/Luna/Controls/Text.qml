import QtQml 2.15
import QtQuick 2.15

import Luna.Styles 1.0 as Styles

// @disable-check M129
Text {
	id: _root
	renderType: Text.NativeRendering
	color: Styles.Colors.getControlText(_root.enabled)
	font: Styles.Fonts.primaryFont
	wrapMode: Text.Wrap
}
