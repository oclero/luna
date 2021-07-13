
import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.platform 1.1 as Platform
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import Luna.Containers 1.0 as Containers
import Luna.Controls 1.0 as Controls
import Luna.Dialogs 1.0 as Dialogs
import Luna.MainWindow 1.0 as MainWindow
import Luna.Styles 1.0 as Styles
import Luna.Render 1.0 as Render
import Luna.Utils 1.0 as Utils

ApplicationWindow {
	id: _root
	width: 1536
	height: 640
	minimumWidth: 530
	minimumHeight: 300
	visible: true
	color: Styles.Colors.windowColorDarker

	MainWindow.MenuBar {
		id: _menuBar

		// TODO Make it work from MenuBar (or with a controller).
		onAboutClicked: {
			_aboutDialog.visible = true
			_aboutDialog.raise()
		}
	}

	// TODO Declared here because a dialog needs a parent window.
	Dialogs.AboutDialog {
		id: _aboutDialog
	}

	MainWindow.ToolBar {
		id: _toolBar
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		leftPanelVisible: _leftPanel.visible
		rightPanelVisible: _rightPanel.visible
		onLeftPanelVisibleChanged: _leftPanel.visible = leftPanelVisible
		onRightPanelVisibleChanged: _rightPanel.visible = rightPanelVisible
	}

	RowLayout {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: _toolBar.bottom
		anchors.bottom: parent.bottom
		spacing: 0

		MainWindow.LeftPanel {
			id: _leftPanel
			Layout.fillHeight: true
			Layout.preferredWidth: implicitWidth
			Layout.alignment: Qt.AlignLeft
		}

		Render.Viewport {
			id: _viewportAdvancedRealTime
			Layout.fillHeight: true
			Layout.fillWidth: true
			renderEngineController: $renderEngineController
			mode: Render.Engine.Mode.RealTime
		}

		Controls.LayoutSpacer {
			visible: _viewportAdvancedRealTime && !_viewportAdvancedRealTime.visible
						&& _viewportRealTime && !_viewportRealTime.visible
		}

		MainWindow.Inspector {
			id: _rightPanel
			Layout.fillHeight: true
			Layout.alignment: Qt.AlignRight
			Layout.preferredWidth: implicitWidth
		}
	}
}
