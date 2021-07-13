import QtQuick 2.15
import Qt.labs.qmlmodels 1.0
import QtQuick.Shapes 1.0
import QtQuick.Layouts 1.15

import Luna.Templates 1.0 as T
import Luna.Styles 1.0 as Styles

T.TreeView {
	property bool hoverEnabled: false
	property font font: Styles.Fonts.primaryFont

	id: _root
	boundsBehavior: Flickable.OvershootBounds
	flickableDirection: Flickable.VerticalFlick
	pixelAligned: true
	clip: true

	styleHints.arrowColor: Styles.Colors.captionTextColor
	styleHints.arrowHoveredColor: Styles.Colors.bodyTextColor
	styleHints.arrowSelectedColor: Styles.Colors.bodyTextColor
	styleHints.arrowDisabledColor: Styles.Colors.captionTextColorDisabled

	styleHints.textColor: Styles.Colors.bodyTextColor
	styleHints.textHoveredColor: Styles.Colors.bodyTextColor
	styleHints.textSelectedColor: Styles.Colors.bodyTextColor
	styleHints.textDisabledColor: Styles.Colors.bodyTextColorDisabled

	styleHints.secondaryTextColor: Styles.Colors.captionTextColor
	styleHints.secondaryTextHoveredColor: Styles.Colors.bodyTextColor
	styleHints.secondaryTextSelectedColor: Styles.Colors.bodyTextColor
	styleHints.secondaryTextDisabledColor: Styles.Colors.captionTextColorDisabled

	styleHints.backgroundEvenColor: Styles.Colors.rowColorEven
	styleHints.backgroundOddColor: Styles.Colors.rowColorOdd
	styleHints.backgroundHoveredColor: Styles.Colors.primaryColorHover
	styleHints.backgroundSelectedColor: Styles.Colors.primaryColor

	QtObject {
		property int hoveredColumn: -1
		property int hoveredRow: -1

		id: _private

		function getColor(column, row, enabled, colorNormal, colorHovered, colorSelected, colorDisabled) {
			if (row === _root.currentIndex.row) {
				return colorSelected
			} else if (row === _private.hoveredRow) {
				return colorHovered
			} else if (!enabled) {
				return colorDisabled
			} else {
				return colorNormal
			}
		}

		function getArrowColor(column, row, enabled) {
			return getColor(column, row, enabled,
											_root.styleHints.arrowColor,
											_root.styleHints.arrowHoveredColor,
											_root.styleHints.arrowSelectedColor,
											_root.styleHints.arrowDisabledColor)
		}

		function getTextColor(column, row, enabled) {
			return getColor(column, row, enabled,
											_root.styleHints.textColor,
											_root.styleHints.textHoveredColor,
											_root.styleHints.textSelectedColor,
											_root.styleHints.textDisabledColor)
		}

		function getSecondaryTextColor(column, row, enabled) {
			return getColor(column, row, enabled,
											_root.styleHints.secondaryTextColor,
											_root.styleHints.secondaryTextHoveredColor,
											_root.styleHints.secondaryTextSelectedColor,
											_root.styleHints.secondaryTextDisabledColor)
		}

		function getBackgroundColor(column, row, enabled) {
			return getColor(column, row, enabled,
											row % 2 ? _root.styleHints.backgroundOddColor : _root.styleHints.backgroundEvenColor,
											_root.styleHints.backgroundHoveredColor,
											_root.styleHints.backgroundSelectedColor,
											_root.styleHints.backgroundDisabledColor)
		}
	}

	delegate: DelegateChooser {
		// The column where the tree is drawn.
		DelegateChoice {
			id: _delegateFirstColumn
			column: 0

			Rectangle {
				property bool hasChildren: T.TreeView.hasChildren
				property bool isExpanded: T.TreeView.isExpanded
				property int depth: T.TreeView.depth

				id: _treeNode
				implicitHeight: Math.ceil(_layoutFirstColumn.implicitHeight)
				implicitWidth: Math.ceil(_layoutFirstColumn.implicitWidth) + Styles.Hints.spacing / 2
				color: _private.getBackgroundColor(model.column, model.row, enabled)

				RowLayout {
					id: _layoutFirstColumn
					anchors.fill: parent
					anchors.leftMargin: 0
					anchors.rightMargin: Styles.Hints.spacing / 2
					spacing: Styles.Hints.spacing / 2
					height: Styles.Hints.menuItemHeight

					TreeViewArrow {
						id: _treeNodeArrow
						color: _private.getArrowColor(model.column, model.row, enabled)
						expanded: _treeNode.isExpanded
						hasChildren: _treeNode.hasChildren
						onClicked: _root.toggleExpanded(model.row)
						Layout.leftMargin: _treeNode.depth * Styles.Hints.spacing / 2
						Layout.alignment: Qt.AlignCenter
						Layout.preferredHeight: Styles.Hints.menuItemHeight
					}
					Text {
						id: _treeNodeLabel
						clip: true
						color: _private.getTextColor(model.column, model.row, enabled)
						font: _root.font
						text: model.display
						elide: Text.ElideRight
						renderType: Text.NativeRendering
						verticalAlignment: Text.AlignVCenter
						horizontalAlignment: Text.AlignLeft
						Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
						Layout.fillWidth: true
						Layout.preferredHeight: Styles.Hints.menuItemHeight
						Layout.preferredWidth: implicitWidth
						Layout.leftMargin: - Styles.Hints.spacing / 2
					}
				}

				// This is necessary because it seems that the mouse is not detected
				// item's whole surface, strangely.
				HoverHandler {
					enabled: _root.hoverEnabled
					onPointChanged: {
						const posInTreeView = _root.mapFromItem(parent, point.position)
						_private.hoveredColumn = _root.columnAtX(posInTreeView.x, true)
						_private.hoveredRow = _root.rowAtY(posInTreeView.y, true)
					}
					onHoveredChanged: {
						if (!hovered) {
							_private.hoveredColumn = -1
							_private.hoveredRow = -1
						}
					}
				}
			}
		}

		//  The remaining columns after the tree column will use this delegate.
		DelegateChoice {
			id: _delegateOtherColumn
			Rectangle {
				id: _treeNodeOtherColumn
				implicitWidth: _labelOtherColumn.x + _labelOtherColumn.width + (Styles.Hints.spacing / 4)
				implicitHeight: Styles.Hints.menuItemHeight
				color: _private.getBackgroundColor(model.column, model.row, enabled)
				Text {
					id: _labelOtherColumn
					x: Styles.Hints.spacing / 4
					color: _private.getSecondaryTextColor(model.column, model.row, enabled)
					font: _root.font
					text: model.display
					elide: Text.ElideRight
					height: parent.height
					renderType: Text.NativeRendering
					verticalAlignment: Text.AlignVCenter
					horizontalAlignment: Text.AlignLeft
				}
				HoverHandler {
					enabled: _root.hoverEnabled
					onPointChanged: {
						const posInTreeView = _root.mapFromItem(parent, point.position)
						_private.hoveredColumn = _root.columnAtX(posInTreeView.x, true)
						_private.hoveredRow = _root.rowAtY(posInTreeView.y, true)
					}
					onHoveredChanged: {
						if (!hovered) {
							_private.hoveredColumn = -1
							_private.hoveredRow = -1
						}
					}
				}
			}
		}
	}

	// Detects mouse when it was not detected by the items.
	HoverHandler {
		enabled: _root.hoverEnabled
		onPointChanged: {
			if (point.position === Qt.point(0, 0)) {
				// Work around HoverHandler bug that happens when opening a popup Menu.
				return
			}
			// Handle mouse over items without children.
			const posInTreeView = _root.mapFromItem(parent, point.position)
			_private.hoveredColumn = _root.columnAtX(posInTreeView.x, true)
			_private.hoveredRow = _root.rowAtY(posInTreeView.y, true)
		}
		onHoveredChanged: {
			if (!hovered) {
				_private.hoveredColumn = -1
				_private.hoveredRow = -1
			}
		}
	}
}
