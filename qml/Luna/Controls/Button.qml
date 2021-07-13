import QtQml 2.15
import QtQuick 2.15
import QtQuick.Templates 2.15 as Templates
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import Luna.Styles 1.0 as Styles
import Luna.Utils 1.0 as Utils

// @disable-check M129
Templates.Button {
	enum Role {
		Primary,
		Secondary
	}

	property alias iconId: _icon.icon
	property int radius: Styles.Hints.radius
	property int role: Button.Role.Secondary
	property alias tooltip: _tooltip.text
	property alias shadowEnabled: _background.shadowEnabled

	id: _root
	font: Styles.Fonts.primaryFont
	height: implicitHeight
	implicitHeight: Styles.Hints.controlHeight
	implicitWidth: _root.text ? _contentLayout.implicitWidth + leftPadding + rightPadding
														: Styles.Hints.controlHeight * 1.25
	bottomPadding: 0
	topPadding: 0
	leftPadding: Styles.Hints.spacing
	rightPadding: Styles.Hints.spacing
	spacing: Styles.Hints.spacing / 2
	text: ""
	hoverEnabled: Qt.styleHints.useHoverEffects
	focusPolicy: Qt.TabFocus
	autoRepeat: false

	background: Utils.ButtonShape {
		id: _background
		radius: _root.radius
		role: _root.role
		down: _root.down
		hovered: _root.hovered
		enabled: _root.enabled
	}

	contentItem: Item {
		id: _contentItem
		anchors.fill: _root
		anchors.leftMargin: _root.text ? _root.leftPadding : 0
		anchors.rightMargin: _root.text ? _root.rightPadding : 0
		anchors.topMargin: _root.topPadding
		anchors.bottomMargin: _root.bottomPadding

		RowLayout {
			id: _contentLayout
			anchors.centerIn: parent
			spacing: _root.spacing

			Utils.SvgIcon {
				id: _icon
				icon: _root.iconId
				color: Styles.Colors.getControlText(_root.enabled)
				width: Styles.Hints.iconSize
				height: Styles.Hints.iconSize
				Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
				visible: status != Image.Null
				opacity: _root.enabled ? 1 : 0.5
			}

			Text {
				id: _text
				color: Styles.Colors.getControlText(_root.enabled)
				elide: Text.ElideRight
				font: _root.font
				horizontalAlignment: Text.AlignHCenter
				renderType: Text.NativeRendering
				text: _root.text
				verticalAlignment: Text.AlignVCenter
				visible: _root.text.length > 0
				Layout.alignment: Qt.AlignVCenter
				Layout.fillWidth: true
				Layout.minimumWidth: Styles.Hints.controlHeight * 1.25
			}
		}
	}

	Utils.FocusBorder {
		id: _focusBorder
		showFocus: _root.visualFocus
	}

	Utils.Tooltip {
		id: _tooltip
	}

	Keys.onPressed: function(event) {
		if (event.isAutoRepeat && event.key === Qt.Key_Space && !_root.autoRepeat) {
			event.accepted = true
		}
	}

	Keys.onReleased: function (event) {
		if (event.isAutoRepeat && event.key === Qt.Key_Space && !_root.autoRepeat) {
			event.accepted = true
		}
	}

	Keys.onEscapePressed: {
		focus = false
	}
}
