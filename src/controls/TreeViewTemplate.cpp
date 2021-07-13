#include <luna/controls/TreeViewTemplate.hpp>

#include "TreeViewTemplatePrivate.hpp"
#include "TreeViewModelAdaptor.hpp"

#include <QObject>
#include <QQmlContext>

namespace luna::controls {
TreeViewTemplate::TreeViewTemplate(QQuickItem* parent)
	: QQuickTableView(*(new TreeViewTemplatePrivate(*this)), parent) {
	// Store private implementation pointer once for all.
	Q_D(TreeViewTemplate);
	_impl = d;

	// QQuickTableView will only ever see the proxy model.
	const auto proxy = QVariant::fromValue(std::addressof(_impl->_proxyModel));
	_impl->QQuickTableViewPrivate::setModelImpl(proxy);
}

TreeViewTemplate::~TreeViewTemplate() = default;

bool TreeViewTemplate::isExpanded(int row) const {
	if (row < 0 || row >= rows()) {
		return false;
	}

	return _impl->_proxyModel.isExpanded(row);
}

bool TreeViewTemplate::hasChildren(int row) const {
	if (row < 0 || row >= rows()) {
		return false;
	}

	return _impl->_proxyModel.hasChildren(row);
}

bool TreeViewTemplate::hasSiblings(int row) const {
	if (row < 0 || row >= rows()) {
		return false;
	}

	return _impl->_proxyModel.hasSiblings(row);
}

int TreeViewTemplate::depth(int row) const {
	if (row < 0 || row >= rows()) {
		return -1;
	}

	return _impl->_proxyModel.depthAtRow(row);
}

void TreeViewTemplate::expand(int row) {
	if (row < 0 || row >= rows()) {
		return;
	}

	if (_impl->_proxyModel.isExpanded(row)) {
		return;
	}

	_impl->_proxyModel.expandRow(row);

	if (const auto delegateItem = _impl->itemAtCell(QPoint(0, row))) {
		if (auto attached = _impl->getAttachedObject(delegateItem)) {
			attached->setIsExpanded(true);
		}
	}

	emit expanded(row);
}

void TreeViewTemplate::expandModelIndex(const QModelIndex& modelIndex) {
	expand(mapFromModel(modelIndex).row());
}

void TreeViewTemplate::collapseModelIndex(const QModelIndex& modelIndex) {
	collapse(mapFromModel(modelIndex).row());
}

void TreeViewTemplate::toggleModelIndexExpanded(const QModelIndex& modelIndex) {
	toggleExpanded(mapFromModel(modelIndex).row());
}

void TreeViewTemplate::collapse(int row) {
	if (row < 0 || row >= rows()) {
		return;
	}

	if (!_impl->_proxyModel.isExpanded(row)) {
		return;
	}

	_impl->_proxyModel.collapseRow(row);

	if (const auto delegateItem = _impl->itemAtCell(QPoint(0, row))) {
		if (auto attached = _impl->getAttachedObject(delegateItem)) {
			attached->setIsExpanded(false);
		}
	}

	emit collapsed(row);
}

void TreeViewTemplate::toggleExpanded(int row) {
	if (isExpanded(row)) {
		collapse(row);
	} else {
		expand(row);
	}
}

bool TreeViewTemplate::isModelIndexExpanded(const QModelIndex& modelIndex) const {
	return isExpanded(mapFromModel(modelIndex).row());
}

int TreeViewTemplate::rowAtY(int y, bool includeSpacing) const {
	// Copied from qquicktableview in Qt6.
	if (!boundingRect().contains(QPointF(x(), y))) {
		return -1;
	}

	const auto vSpace = _impl->cellSpacing.height();
	auto currentRowEnd = _impl->loadedTableOuterRect.y() - contentY();
	auto foundRow = -1;

	for (auto const row : qAsConst(_impl->loadedRows).keys()) {
		currentRowEnd += _impl->effectiveRowHeight(row);
		if (y < currentRowEnd) {
			foundRow = row;
			break;
		}
		currentRowEnd += vSpace;
		if (!includeSpacing && y < currentRowEnd) {
			// Hit spacing.
			return -1;
		}
		if (includeSpacing && y < currentRowEnd - (vSpace / 2)) {
			foundRow = row;
			break;
		}
	}

	return foundRow;
}

int TreeViewTemplate::columnAtX(int x, bool includeSpacing) const {
	// Copied from qquicktableview in Qt6.
	if (!boundingRect().contains(QPointF(x, y()))) {
		return -1;
	}

	const auto hSpace = _impl->cellSpacing.width();
	auto currentColumnEnd = _impl->loadedTableOuterRect.x() - contentX();
	auto foundColumn = -1;

	for (auto const column : qAsConst(_impl->loadedColumns).keys()) {
		currentColumnEnd += _impl->effectiveColumnWidth(column);
		if (x < currentColumnEnd) {
			foundColumn = column;
			break;
		}
		currentColumnEnd += hSpace;
		if (!includeSpacing && x < currentColumnEnd) {
			// Hit spacing.
			return -1;
		} else if (includeSpacing && x < currentColumnEnd - (hSpace / 2)) {
			foundColumn = column;
			break;
		}
	}

	return foundColumn;
}

QModelIndex TreeViewTemplate::viewIndex(int column, int row) const {
	return _impl->_proxyModel.index(row, column);
}

QModelIndex TreeViewTemplate::mapToModel(const QModelIndex& viewIndex) const {
	return _impl->_proxyModel.mapToModel(viewIndex);
}

QModelIndex TreeViewTemplate::mapFromModel(const QModelIndex& modelIndex) const {
	return _impl->_proxyModel.mapFromModel(modelIndex);
}

QModelIndex TreeViewTemplate::currentIndex() const {
	return mapFromModel(currentModelIndex());
}

void TreeViewTemplate::setCurrentIndex(const QModelIndex& index) {
	setCurrentModelIndex(mapToModel(index));
}

QModelIndex TreeViewTemplate::currentModelIndex() const {
	return _impl->_currentModelIndex;
}

void TreeViewTemplate::setCurrentModelIndex(const QModelIndex& modelIndex) {
	if (_impl->_currentModelIndex == modelIndex) {
		return;
	}

	_impl->_currentModelIndex = modelIndex;
	_impl->_currentModelIndexEmitted = modelIndex;
	_impl->_currentItemEmitted = currentItem();

	emit currentIndexChanged();
	emit currentModelIndexChanged();
	emit currentItemChanged();
}

QQuickItem* TreeViewTemplate::currentItem() const {
	return itemAtModelIndex(currentModelIndex());
}

QQuickItem* TreeViewTemplate::itemAtCell(const QPoint& cell) const {
	const auto modelIndex = _impl->modelIndexAtCell(cell);

	if (!_impl->loadedItems.contains(modelIndex)) {
		return nullptr;
	}

	return _impl->loadedItems.value(modelIndex)->item;
}

QQuickItem* TreeViewTemplate::itemAtIndex(const QModelIndex& viewIndex) const {
	return itemAtCell(QPoint(viewIndex.column(), viewIndex.row()));
}

QQuickItem* TreeViewTemplate::itemAtModelIndex(const QModelIndex& modelIndex) const {
	return itemAtIndex(mapFromModel(modelIndex));
}

void TreeViewTemplate::keyPressEvent(QKeyEvent* e) {
	switch (e->key()) {
		case Qt::Key_Up:
			_impl->moveCurrentViewIndex(0, -1);
			break;
		case Qt::Key_Down:
			_impl->moveCurrentViewIndex(0, 1);
			break;
		case Qt::Key_Left:
			if (isModelIndexExpanded(_impl->_currentModelIndex)) {
				collapseModelIndex(_impl->_currentModelIndex);
			} else {
				_impl->moveCurrentViewIndex(0, -1);
			}
			break;
		case Qt::Key_Right:
			if (!isModelIndexExpanded(_impl->_currentModelIndex)) {
				expandModelIndex(_impl->_currentModelIndex);
			} else {
				_impl->moveCurrentViewIndex(0, 1);
			}
			break;
		case Qt::Key_Space:
			toggleModelIndexExpanded(_impl->_currentModelIndex);
			break;
		default:
			break;
	}
}

void TreeViewTemplate::mousePressEvent(QMouseEvent* e) {
	QQuickTableView::mousePressEvent(e);

	_impl->_contentItemPosAtMousePress = contentItem()->position();
}

void TreeViewTemplate::mouseReleaseEvent(QMouseEvent* e) {
	QQuickTableView::mouseReleaseEvent(e);

	// Clicking on a tree transfers focus to it
	setFocus(true);

	if (contentItem()->position() != _impl->_contentItemPosAtMousePress) {
		// content item was flicked, which should cancel setting current index
		return;
	}

	const auto column = columnAtX(e->pos().x(), true);
	const auto row = rowAtY(e->pos().y(), true);
	if (column == -1 || row == -1) {
		return;
	}

	setCurrentModelIndex(mapToModel(viewIndex(0, row)));
}

void TreeViewTemplate::mouseDoubleClickEvent(QMouseEvent* e) {
	QQuickTableView::mouseDoubleClickEvent(e);

	const auto row = rowAtY(e->pos().y(), true);
	if (row == -1) {
		return;
	}

	toggleExpanded(row);
}

void TreeViewTemplate::viewportMoved(Qt::Orientations orientation) {
	QQuickTableView::viewportMoved(orientation);

	_impl->checkForPropertyChanges();
}

TreeViewAttached* TreeViewTemplate::qmlAttachedProperties(QObject* obj) {
	return new TreeViewAttached(obj);
}

TreeViewStyleHints* TreeViewTemplate::styleHints() const {
	return &_impl->_styleHints;
}
} // namespace luna::controls
