pragma Singleton

import QtQuick 2.15

QtObject {
	id: _root
	readonly property int animationDuration: 150
	readonly property int spacing: 16
	readonly property int radius: 6
	readonly property int iconSize: 16
	readonly property int borderWidth: 1
	readonly property int focusBorderWidth: 3
	readonly property int controlDefaultWidth: 200
	readonly property int controlHeight: 28
	readonly property int controlWidthSmall: 20
	readonly property int sliderHandleSize: controlWidthSmall
	readonly property int tooltipDelay: 500
	readonly property int tooltipTimeout: 5000
	readonly property int sliderDefaultWidth: controlDefaultWidth
	readonly property int menuItemHeight: 24
	readonly property bool hoverEnabled: true
	readonly property int scrollBarFullThickness: 10
	readonly property int scrollBarSmallThickness: 6
	readonly property int scrollStep: 100
	readonly property int scrollStepAutoRepeat: 600
	readonly property int scrollMargin: spacing * 2
}
