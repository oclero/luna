#include "TreeViewModelAdaptor.hpp"

#include <math.h>
#include <QStack>
#include <QDebug>

//#define QQUICKTREEMODELADAPTOR_DEBUG
#if defined(QQUICKTREEMODELADAPTOR_DEBUG) && !defined(QT_TESTLIB_LIB)
#	define ASSERT_CONSISTENCY() \
		Q_ASSERT_X(testConsistency(true /* dumpOnFail */), Q_FUNC_INFO, "Consistency test failed")
#else
#	define ASSERT_CONSISTENCY qt_noop
#endif

TreeViewModelAdaptor::TreeViewModelAdaptor(QObject* parent)
	: QAbstractItemModel(parent) {}

QAbstractItemModel* TreeViewModelAdaptor::model() const {
	return _model;
}

void TreeViewModelAdaptor::setModel(QAbstractItemModel* arg) {
	struct Cx {
		const char* signal;
		const char* slot;
	};
	// clang-format off
	static const Cx connections[] = {
		{ SIGNAL(destroyed(QObject*)),
			SLOT(modelHasBeenDestroyed()) },
		{ SIGNAL(modelReset()),
			SLOT(modelHasBeenReset()) },
		{ SIGNAL(dataChanged(const QModelIndex&, const QModelIndex&, const QVector<int>&)),
			SLOT(modelDataChanged(const QModelIndex&, const QModelIndex&, const QVector<int>&)) },
		{ SIGNAL(layoutAboutToBeChanged(const QList<QPersistentModelIndex>&, QAbstractItemModel::LayoutChangeHint)),
			SLOT(modelLayoutAboutToBeChanged(const QList<QPersistentModelIndex>&, QAbstractItemModel::LayoutChangeHint)) },
		{ SIGNAL(layoutChanged(const QList<QPersistentModelIndex>&, QAbstractItemModel::LayoutChangeHint)),
			SLOT(modelLayoutChanged(const QList<QPersistentModelIndex>&, QAbstractItemModel::LayoutChangeHint)) },
		{ SIGNAL(rowsAboutToBeInserted(const QModelIndex&, int, int)),
			SLOT(modelRowsAboutToBeInserted(const QModelIndex&, int, int)) },
		{ SIGNAL(rowsInserted(const QModelIndex&, int, int)),
			SLOT(modelRowsInserted(const QModelIndex&, int, int)) },
		{ SIGNAL(rowsAboutToBeRemoved(const QModelIndex&, int, int)),
			SLOT(modelRowsAboutToBeRemoved(const QModelIndex&, int, int)) },
		{ SIGNAL(rowsRemoved(const QModelIndex&, int, int)),
			SLOT(modelRowsRemoved(const QModelIndex&, int, int)) },
		{ SIGNAL(rowsAboutToBeMoved(const QModelIndex&, int, int, const QModelIndex&, int)),
			SLOT(modelRowsAboutToBeMoved(const QModelIndex&, int, int, const QModelIndex&, int)) },
		{ SIGNAL(rowsMoved(const QModelIndex&, int, int, const QModelIndex&, int)),
			SLOT(modelRowsMoved(const QModelIndex&, int, int, const QModelIndex&, int)) },
		{ nullptr, nullptr } };
	// clang-format on

	if (_model != arg) {
		if (_model) {
			for (const auto* c = &connections[0]; c->signal; c++) {
				disconnect(_model, c->signal, this, c->slot);
			}
		}

		clearModelData();
		_model = arg;

		if (_model) {
			for (const auto* c = &connections[0]; c->signal; c++) {
				connect(_model, c->signal, this, c->slot);
			}

			showModelTopLevelItems();
		}

		emit modelChanged(arg);
	}
}

void TreeViewModelAdaptor::clearModelData() {
	beginResetModel();
	_items.clear();
	_expandedItems.clear();
	endResetModel();
}

const QModelIndex& TreeViewModelAdaptor::rootIndex() const {
	return _rootIndex;
}

void TreeViewModelAdaptor::setRootIndex(const QModelIndex& idx) {
	if (_rootIndex == idx) {
		return;
	}

	if (_model) {
		clearModelData();
	}

	_rootIndex = idx;

	if (_model) {
		showModelTopLevelItems();
	}

	emit rootIndexChanged();
}

void TreeViewModelAdaptor::resetRootIndex() {
	setRootIndex({});
}

QModelIndex TreeViewModelAdaptor::index(int row, int column, const QModelIndex& parent) const {
	return hasIndex(row, column, parent) ? createIndex(row, column) : QModelIndex();
}

QModelIndex TreeViewModelAdaptor::parent(const QModelIndex& child) const {
	Q_UNUSED(child)
	return {};
}

QHash<int, QByteArray> TreeViewModelAdaptor::roleNames() const {
	return _model ? _model->roleNames() : QHash<int, QByteArray>();
}

int TreeViewModelAdaptor::rowCount(const QModelIndex&) const {
	return _model ? _items.count() : 0;
}

int TreeViewModelAdaptor::columnCount(const QModelIndex& parent) const {
	return _model ? _model->columnCount(parent) : 0;
}

QVariant TreeViewModelAdaptor::data(const QModelIndex& index, int role) const {
	return _model ? _model->data(mapToModel(index), role) : QVariant();
}

bool TreeViewModelAdaptor::setData(const QModelIndex& index, const QVariant& value, int role) {
	return _model ? _model->setData(mapToModel(index), value, role) : false;
}

QVariant TreeViewModelAdaptor::headerData(int section, Qt::Orientation orientation, int role) const {
	return _model->headerData(section, orientation, role);
}

int TreeViewModelAdaptor::depthAtRow(int row) const {
	if (row < 0 || row >= _items.count()) {
		return 0;
	}
	return _items.at(row).depth;
}

int TreeViewModelAdaptor::itemIndex(const QModelIndex& index) const {
	// This is basically a plagiarism of QTreeViewPrivate::viewIndex().
	if (!index.isValid() || index == _rootIndex || _items.isEmpty()) {
		return -1;
	}

	const auto totalCount = _items.count();

	// We start nearest to the lastViewedItem.
	auto localCount = qMin(_lastItemIndex - 1, totalCount - _lastItemIndex);

	for (auto i = 0; i < localCount; ++i) {
		const auto& item1 = _items.at(_lastItemIndex + i);
		if (item1.index == index) {
			_lastItemIndex = _lastItemIndex + i;
			return _lastItemIndex;
		}
		const auto& item2 = _items.at(_lastItemIndex - i - 1);
		if (item2.index == index) {
			_lastItemIndex = _lastItemIndex - i - 1;
			return _lastItemIndex;
		}
	}

	for (auto j = qMax(0, _lastItemIndex + localCount); j < totalCount; ++j) {
		const auto& item = _items.at(j);
		if (item.index == index) {
			_lastItemIndex = j;
			return j;
		}
	}

	for (auto j = qMin(totalCount, _lastItemIndex - localCount) - 1; j >= 0; --j) {
		const auto& item = _items.at(j);
		if (item.index == index) {
			_lastItemIndex = j;
			return j;
		}
	}

	// Nothing found.
	return -1;
}

bool TreeViewModelAdaptor::isVisible(const QModelIndex& index) {
	return itemIndex(index) != -1;
}

bool TreeViewModelAdaptor::childrenVisible(const QModelIndex& index) {
	return (index == _rootIndex && !_items.isEmpty()) || (_expandedItems.contains(index) && isVisible(index));
}

QModelIndex TreeViewModelAdaptor::mapToModel(const QModelIndex& index) const {
	const auto row = index.row();
	if (row < 0 || row > _items.count() - 1) {
		return QModelIndex();
	}

	const QModelIndex sourceIndex = _items.at(row).index;
	return _model->index(sourceIndex.row(), index.column(), sourceIndex.parent());
}

QModelIndex TreeViewModelAdaptor::mapFromModel(const QModelIndex& index) const {
	auto row = -1;
	for (auto i = 0; i < _items.count(); ++i) {
		const QModelIndex proxyIndex = _items[i].index;
		if (proxyIndex.row() == index.row() && proxyIndex.parent() == index.parent()) {
			row = i;
			break;
		}
	}

	if (row == -1) {
		return QModelIndex();
	}

	return this->index(row, index.column());
}

QModelIndex TreeViewModelAdaptor::mapToModel(int row) const {
	if (row < 0 || row >= _items.count()) {
		return QModelIndex();
	}
	return _items.at(row).index;
}

QItemSelection TreeViewModelAdaptor::selectionForRowRange(const QModelIndex& fromIndex, const QModelIndex& toIndex) const {
	auto from = itemIndex(fromIndex);
	auto to = itemIndex(toIndex);
	if (from == -1) {
		if (to == -1) {
			return QItemSelection();
		}
		return QItemSelection(toIndex, toIndex);
	}

	to = qMax(to, 0);
	if (from > to) {
		qSwap(from, to);
	}

	typedef QPair<QModelIndex, QModelIndex> MIPair;
	typedef QHash<QModelIndex, MIPair> MI2MIPairHash;
	MI2MIPairHash ranges;
	QModelIndex firstIndex = _items.at(from).index;
	QModelIndex lastIndex = firstIndex;
	QModelIndex previousParent = firstIndex.parent();
	bool selectLastRow = false;

#pragma warning(push)
#pragma warning(disable : 6282)
	// Copied from QQuickQtreeViewModelAdaptor.
	// I've not tried to understand why they do an assignment in the loop condition.
	for (auto i = from + 1; i <= to || (selectLastRow = true); i++) {
#pragma warning(pop)
		// We run an extra iteration to make sure the last row is
		// added to the selection. (And also to avoid duplicating
		// the insertion code.)
		QModelIndex index;
		QModelIndex parent;
		if (!selectLastRow) {
			index = _items.at(i).index;
			parent = index.parent();
		}
		if (selectLastRow || previousParent != parent) {
			const auto& it = ranges.find(previousParent);
			if (it == ranges.end()) {
				ranges.insert(previousParent, MIPair(firstIndex, lastIndex));
			} else {
				it->second = lastIndex;
			}

			if (selectLastRow) {
				break;
			}

			firstIndex = index;
			previousParent = parent;
		}
		lastIndex = index;
	}

	QItemSelection sel;
	sel.reserve(ranges.count());
	for (const auto& pair : qAsConst(ranges)) {
		sel.append(QItemSelectionRange(pair.first, pair.second));
	}

	return sel;
}

void TreeViewModelAdaptor::showModelTopLevelItems(bool doInsertRows) {
	if (!_model) {
		return;
	}

	if (_model->hasChildren(_rootIndex) && _model->canFetchMore(_rootIndex)) {
		_model->fetchMore(_rootIndex);
	}

	const long topLevelRowCount = _model->rowCount(_rootIndex);
	if (topLevelRowCount == 0) {
		return;
	}

	showModelChildItems(TreeItem(_rootIndex), 0, topLevelRowCount - 1, doInsertRows);
}

void TreeViewModelAdaptor::showModelChildItems(const TreeItem& parentItem, int start, int end, bool doInsertRows, bool doExpandPendingRows) {
	const QModelIndex& parentIndex = parentItem.index;
	auto rowIdx = parentIndex.isValid() && parentIndex != _rootIndex ? itemIndex(parentIndex) + 1 : 0;
	Q_ASSERT(rowIdx == 0 || parentItem.expanded);

	if (parentIndex.isValid() && parentIndex != _rootIndex && (rowIdx == 0 || !parentItem.expanded)) {
		return;
	}

	if (_model->rowCount(parentIndex) == 0) {
		if (_model->hasChildren(parentIndex) && _model->canFetchMore(parentIndex)) {
			_model->fetchMore(parentIndex);
		}
		return;
	}
	const auto insertCount = end - start + 1;
	int startIdx;
	if (start == 0) {
		startIdx = rowIdx;
	} else {
		// Prefer to insert before next sibling instead of after last child of previous, as
		// the latter is potentially buggy, see QTBUG-66062.
		const auto& nextSiblingIdx = _model->index(end + 1, 0, parentIndex);
		if (nextSiblingIdx.isValid()) {
			startIdx = itemIndex(nextSiblingIdx);
		} else {
			const auto& prevSiblingIdx = _model->index(start - 1, 0, parentIndex);
			startIdx = lastChildIndex(prevSiblingIdx) + 1;
		}
	}

	const auto rowDepth = rowIdx == 0 ? 0 : parentItem.depth + 1;
	if (doInsertRows) {
		beginInsertRows(QModelIndex(), startIdx, startIdx + insertCount - 1);
	}
	_items.reserve(_items.count() + insertCount);

	for (int i = 0; i < insertCount; i++) {
		const auto& cmi = _model->index(start + i, 0, parentIndex);
		const auto expanded = _expandedItems.contains(cmi);
		_items.insert(startIdx + i, TreeItem(cmi, rowDepth, expanded));
		if (expanded) {
			_itemsToExpand.append(&_items[startIdx + i]);
		}
	}
	if (doInsertRows) {
		endInsertRows();
	}

	if (doExpandPendingRows) {
		expandPendingRows(doInsertRows);
	}
}


void TreeViewModelAdaptor::expand(const QModelIndex& idx) {
	ASSERT_CONSISTENCY();
	if (!_model) {
		return;
	}

	Q_ASSERT(!idx.isValid() || idx.model() == _model);

	if (!idx.isValid() || !_model->hasChildren(idx)) {
		return;
	}
	if (_expandedItems.contains(idx)) {
		return;
	}

	const auto row = itemIndex(idx);
	if (row != -1) {
		expandRow(row);
	} else {
		_expandedItems.insert(idx);
	}
	ASSERT_CONSISTENCY();

	emit expanded(idx);
}

void TreeViewModelAdaptor::collapse(const QModelIndex& idx) {
	ASSERT_CONSISTENCY();
	if (!_model) {
		return;
	}

	Q_ASSERT(!idx.isValid() || idx.model() == _model);

	if (!idx.isValid() || !_model->hasChildren(idx)) {
		return;
	}
	if (!_expandedItems.contains(idx)) {
		return;
	}

	const auto row = itemIndex(idx);
	if (row != -1) {
		collapseRow(row);
	} else {
		_expandedItems.remove(idx);
	}
	ASSERT_CONSISTENCY();

	emit collapsed(idx);
}

bool TreeViewModelAdaptor::isExpanded(const QModelIndex& index) const {
	ASSERT_CONSISTENCY();
	if (!_model) {
		return false;
	}

	Q_ASSERT(!index.isValid() || index.model() == _model);
	return !index.isValid() || _expandedItems.contains(index);
}

bool TreeViewModelAdaptor::isExpanded(int row) const {
	if (row < 0 || row >= _items.count()) {
		return false;
	}
	return _items.at(row).expanded;
}

bool TreeViewModelAdaptor::hasChildren(int row) const {
	if (row < 0 || row >= _items.count()) {
		return false;
	}
	return _model->hasChildren(_items[row].index);
}

bool TreeViewModelAdaptor::hasSiblings(int row) const {
	const auto& index = mapToModel(row);
	return index.row() != _model->rowCount(index.parent()) - 1;
}

void TreeViewModelAdaptor::expandRow(int n) {
	if (!_model || isExpanded(n)) {
		return;
	}

	auto& item = _items[n];

	if ((item.index.flags() & Qt::ItemNeverHasChildren) || !_model->hasChildren(item.index)) {
		return;
	}

	item.expanded = true;
	_expandedItems.insert(item.index);
	QVector<int> changedRole(1, ExpandedRole);
	emit dataChanged(index(n, _column), index(n, _column), changedRole);

	_itemsToExpand.append(&item);
	expandPendingRows();
}

void TreeViewModelAdaptor::expandPendingRows(bool doInsertRows) {
	while (!_itemsToExpand.isEmpty()) {
		auto* item = _itemsToExpand.takeFirst();
		Q_ASSERT(item->expanded);

		const auto& index = item->index;
		const auto childrenCount = _model->rowCount(index);
		if (childrenCount == 0) {
			if (_model->hasChildren(index) && _model->canFetchMore(index)) {
				_model->fetchMore(index);
			}
			continue;
		}

		// TODO Pre-compute the total number of items made visible
		// so that we only call a single beginInsertRows()/endInsertRows()
		// pair per expansion (same as we do for collapsing).
		showModelChildItems(*item, 0, childrenCount - 1, doInsertRows, false);
	}
}

void TreeViewModelAdaptor::collapseRow(int n) {
	if (!_model || !isExpanded(n)) {
		return;
	}

	SignalFreezer aggregator(this);

	auto& item = _items[n];
	item.expanded = false;
	_expandedItems.remove(item.index);
	QVector<int> changedRole(1, ExpandedRole);
	queueDataChanged(index(n, _column), index(n, _column), changedRole);
	const auto childrenCount = _model->rowCount(item.index);
	if ((item.index.flags() & Qt::ItemNeverHasChildren) || !_model->hasChildren(item.index) || childrenCount == 0) {
		return;
	}

	const auto& emi = _model->index(childrenCount - 1, 0, item.index);
	const auto lastIndex = lastChildIndex(emi);
	removeVisibleRows(n + 1, lastIndex);
}

int TreeViewModelAdaptor::lastChildIndex(const QModelIndex& index) {
	if (!_expandedItems.contains(index)) {
		return itemIndex(index);
	}

	QModelIndex parent = index.parent();
	QModelIndex nextSiblingIndex;
	while (parent.isValid()) {
		nextSiblingIndex = parent.sibling(parent.row() + 1, 0);
		if (nextSiblingIndex.isValid()) {
			break;
		}
		parent = parent.parent();
	}

	const auto firstIndex = nextSiblingIndex.isValid() ? itemIndex(nextSiblingIndex) : _items.count();
	return firstIndex - 1;
}

void TreeViewModelAdaptor::removeVisibleRows(int startIndex, int endIndex, bool doRemoveRows) {
	if (startIndex < 0 || endIndex < 0 || startIndex > endIndex) {
		return;
	}

	if (doRemoveRows) {
		beginRemoveRows(QModelIndex(), startIndex, endIndex);
	}

	_items.erase(_items.begin() + startIndex, _items.begin() + endIndex + 1);

	if (doRemoveRows) {
		endRemoveRows();

		// We need to update the model index for all the items below the removed ones.
		const auto lastIndex = _items.count() - 1;
		if (startIndex <= lastIndex) {
			const auto& topLeft = index(startIndex, 0, QModelIndex());
			const auto& bottomRight = index(lastIndex, 0, QModelIndex());
			const QVector<int> changedRole(1, ModelIndexRole);
			queueDataChanged(topLeft, bottomRight, changedRole);
		}
	}
}

void TreeViewModelAdaptor::modelHasBeenDestroyed() {
	// The model has been deleted. This should behave as if no model was set.
	clearModelData();
	emit modelChanged(nullptr);
}

void TreeViewModelAdaptor::modelHasBeenReset() {
	clearModelData();

	showModelTopLevelItems();
	ASSERT_CONSISTENCY();
}

void TreeViewModelAdaptor::modelDataChanged(const QModelIndex& topLeft, const QModelIndex& bottomRigth, const QVector<int>& roles) {
	Q_ASSERT(topLeft.parent() == bottomRigth.parent());
	const auto& parent = topLeft.parent();
	if (parent.isValid() && !childrenVisible(parent)) {
		ASSERT_CONSISTENCY();
		return;
	}

	auto topIndex = itemIndex(topLeft);
	if (topIndex == -1) {
		// 'parent' is not visible anymore, though it's been expanded previously.
		return;
	}

	for (auto i = topLeft.row(); i <= bottomRigth.row(); i++) {
		// Group items with same parent to minize the number of 'dataChanged()' emits
		auto bottomIndex = topIndex;
		while (bottomIndex < _items.count()) {
			const QModelIndex& idx = _items.at(bottomIndex).index;
			if (idx.parent() != parent) {
				--bottomIndex;
				break;
			}
			if (idx.row() == bottomRigth.row()) {
				break;
			}
			++bottomIndex;
		}
		emit dataChanged(index(topIndex, _column), index(bottomIndex, _column), roles);

		i += bottomIndex - topIndex;
		if (i == bottomRigth.row()) {
			break;
		}
		topIndex = bottomIndex + 1;
		while (topIndex < _items.count() && _items.at(topIndex).index.parent() != parent) {
			topIndex++;
		}
	}
	ASSERT_CONSISTENCY();
}

void TreeViewModelAdaptor::modelLayoutAboutToBeChanged(const QList<QPersistentModelIndex>& parents, QAbstractItemModel::LayoutChangeHint hint) {
	ASSERT_CONSISTENCY();
	Q_UNUSED(parents)
	Q_UNUSED(hint)
}

void TreeViewModelAdaptor::modelLayoutChanged(const QList<QPersistentModelIndex>& parents, QAbstractItemModel::LayoutChangeHint hint) {
	Q_UNUSED(hint)
	if (parents.isEmpty()) {
		_items.clear();
		showModelTopLevelItems(false /*doInsertRows*/);
		emit dataChanged(index(0, _column), index(_items.count() - 1, _column));
	}

	for (const auto& pmi : parents) {
		if (_expandedItems.contains(pmi)) {
			const auto row = itemIndex(pmi);
			if (row != -1) {
				const auto rowCount = _model->rowCount(pmi);
				if (rowCount > 0) {
					const auto& lmi = _model->index(rowCount - 1, 0, pmi);
					const auto lastRow = lastChildIndex(lmi);
					removeVisibleRows(row + 1, lastRow, false /*doRemoveRows*/);
					showModelChildItems(_items.at(row), 0, rowCount - 1, false /*doInsertRows*/);
					emit dataChanged(index(row + 1, _column), index(lastRow, _column));
				}
			}
		}
	}
	ASSERT_CONSISTENCY();
}

void TreeViewModelAdaptor::modelRowsAboutToBeInserted(const QModelIndex& parent, int start, int end) {
	Q_UNUSED(parent)
	Q_UNUSED(start)
	Q_UNUSED(end)
	ASSERT_CONSISTENCY();
}

void TreeViewModelAdaptor::modelRowsInserted(const QModelIndex& parent, int start, int end) {
	TreeItem item;
	const auto parentRow = itemIndex(parent);
	if (parentRow >= 0) {
		const auto& parentIndex = index(parentRow, _column);
		QVector<int> changedRole(1, HasChildrenRole);
		queueDataChanged(parentIndex, parentIndex, changedRole);
		item = _items.at(parentRow);
		if (!item.expanded) {
			ASSERT_CONSISTENCY();
			return;
		}
	} else if (parent == _rootIndex) {
		item = TreeItem(parent);
	} else {
		ASSERT_CONSISTENCY();
		return;
	}
	showModelChildItems(item, start, end);
	ASSERT_CONSISTENCY();
}

void TreeViewModelAdaptor::modelRowsAboutToBeRemoved(const QModelIndex& parent, int start, int end) {
	ASSERT_CONSISTENCY();
	enableSignalAggregation();
	if (parent == _rootIndex || childrenVisible(parent)) {
		const auto& smi = _model->index(start, 0, parent);
		const auto startIndex = itemIndex(smi);
		const auto& emi = _model->index(end, 0, parent);
		auto endIndex = -1;
		if (isExpanded(emi)) {
			const auto rowCount = _model->rowCount(emi);
			if (rowCount > 0) {
				const auto& idx = _model->index(rowCount - 1, 0, emi);
				endIndex = lastChildIndex(idx);
			}
		}
		if (endIndex == -1) {
			endIndex = itemIndex(emi);
		}

		removeVisibleRows(startIndex, endIndex);
	}

	for (auto r = start; r <= end; r++) {
		const auto& cmi = _model->index(r, 0, parent);
		_expandedItems.remove(cmi);
	}
}

void TreeViewModelAdaptor::modelRowsRemoved(const QModelIndex& parent, int start, int end) {
	Q_UNUSED(start)
	Q_UNUSED(end)
	const auto parentRow = itemIndex(parent);
	if (parentRow >= 0) {
		const auto& parentIndex = index(parentRow, _column);
		QVector<int> changedRole(1, HasChildrenRole);
		queueDataChanged(parentIndex, parentIndex, changedRole);
	}
	disableSignalAggregation();
	ASSERT_CONSISTENCY();
}

void TreeViewModelAdaptor::modelRowsAboutToBeMoved(const QModelIndex& sourceParent, int sourceStart, int sourceEnd, const QModelIndex& destinationParent, int destinationRow) {
	ASSERT_CONSISTENCY();
	enableSignalAggregation();
	_visibleRowsMoved = false;
	if (!childrenVisible(sourceParent)) {
		// Do nothing now. See modelRowsMoved() below.
		return;
	}

	if (!childrenVisible(destinationParent)) {
		modelRowsAboutToBeRemoved(sourceParent, sourceStart, sourceEnd);
		// If the destination parent has no children,
		// we'll need to report a change on the HasChildrenRole.
		if (isVisible(destinationParent) && _model->rowCount(destinationParent) == 0) {
			const auto& topLeft = index(itemIndex(destinationParent), 0, {});
			const auto& bottomRight = topLeft;
			const QVector<int> changedRole(1, HasChildrenRole);
			queueDataChanged(topLeft, bottomRight, changedRole);
		}
	} else {
		auto depthDifference = -1;
		if (destinationParent.isValid()) {
			const auto destParentIndex = itemIndex(destinationParent);
			depthDifference = _items.at(destParentIndex).depth;
		}
		if (sourceParent.isValid()) {
			const auto sourceParentIndex = itemIndex(sourceParent);
			depthDifference -= _items.at(sourceParentIndex).depth;
		} else {
			depthDifference++;
		}

		const auto startIndex = itemIndex(_model->index(sourceStart, 0, sourceParent));
		const auto& emi = _model->index(sourceEnd, 0, sourceParent);
		int endIndex = -1;
		if (isExpanded(emi)) {
			const auto rowCount = _model->rowCount(emi);
			if (rowCount > 0) {
				endIndex = lastChildIndex(_model->index(rowCount - 1, 0, emi));
			}
		}
		if (endIndex == -1) {
			endIndex = itemIndex(emi);
		}

		auto destIndex = -1;
		if (destinationRow == _model->rowCount(destinationParent)) {
			const auto& emi = _model->index(destinationRow - 1, 0, destinationParent);
			destIndex = lastChildIndex(emi) + 1;
		} else {
			destIndex = itemIndex(_model->index(destinationRow, 0, destinationParent));
		}

		const auto totalMovedCount = endIndex - startIndex + 1;

		// This beginMoveRows() is matched by a endMoveRows() in the modelRowsMoved() method below.
		_visibleRowsMoved = startIndex != destIndex && beginMoveRows({}, startIndex, endIndex, {}, destIndex);

		const auto& buffer = _items.mid(startIndex, totalMovedCount);
		int bufferCopyOffset;
		if (destIndex > endIndex) {
			for (auto i = endIndex + 1; i < destIndex; i++) {
				// Fast move from 1st to 2nd position.
				_items.swapItemsAt(i, i - totalMovedCount);
			}
			bufferCopyOffset = destIndex - totalMovedCount;
		} else {
			// NOTE: we will not enter this loop if startIndex == destIndex.
			for (auto i = startIndex - 1; i >= destIndex; i--) {
				// Fast move from 1st to 2nd position.
				_items.swapItemsAt(i, i + totalMovedCount);
			}
			bufferCopyOffset = destIndex;
		}
		for (auto i = 0; i < buffer.length(); i++) {
			auto item = buffer.at(i);
			item.depth += depthDifference;
			_items.replace(bufferCopyOffset + i, item);
		}

		/* If both source and destination items are visible, the indexes of
		 * all the items in between will change. If they share the same
		 * parent, then this is all; however, if they belong to different
		 * parents, their bottom siblings will also get displaced, so their
		 * index also needs to be updated.
		 * Given that the bottom siblings of the top moved elements are
		 * already included in the update (since they lie between the
		 * source and the dest elements), we only need to worry about the
		 * siblings of the bottom moved element.
		 */
		const int top = qMin(startIndex, bufferCopyOffset);
		int bottom = qMax(endIndex, bufferCopyOffset + totalMovedCount - 1);
		if (sourceParent != destinationParent) {
			const QModelIndex& bottomParent = bottom == endIndex ? sourceParent : destinationParent;

			const int rowCount = _model->rowCount(bottomParent);
			if (rowCount > 0)
				bottom = qMax(bottom, lastChildIndex(_model->index(rowCount - 1, 0, bottomParent)));
		}
		const QModelIndex& topLeft = index(top, 0, QModelIndex());
		const QModelIndex& bottomRight = index(bottom, 0, QModelIndex());
		const QVector<int> changedRole(1, ModelIndexRole);
		queueDataChanged(topLeft, bottomRight, changedRole);

		if (depthDifference != 0) {
			const QModelIndex& topLeft = index(bufferCopyOffset, 0, QModelIndex());
			const QModelIndex& bottomRight = index(bufferCopyOffset + totalMovedCount - 1, 0, QModelIndex());
			const QVector<int> changedRole(1, DepthRole);
			queueDataChanged(topLeft, bottomRight, changedRole);
		}
	}
}

void TreeViewModelAdaptor::modelRowsMoved(const QModelIndex& sourceParent, int sourceStart, int sourceEnd,
	const QModelIndex& destinationParent, int destinationRow) {
	if (!childrenVisible(sourceParent)) {
		modelRowsInserted(destinationParent, destinationRow, destinationRow + sourceEnd - sourceStart);
	} else if (!childrenVisible(destinationParent)) {
		modelRowsRemoved(sourceParent, sourceStart, sourceEnd);
	}

	if (_visibleRowsMoved)
		endMoveRows();

	if (isVisible(sourceParent) && _model->rowCount(sourceParent) == 0) {
		int parentRow = itemIndex(sourceParent);
		collapseRow(parentRow);
		const QModelIndex& topLeft = index(parentRow, 0, QModelIndex());
		const QModelIndex& bottomRight = topLeft;
		const QVector<int> changedRole{ ExpandedRole, HasChildrenRole };
		queueDataChanged(topLeft, bottomRight, changedRole);
	}

	disableSignalAggregation();

	ASSERT_CONSISTENCY();
}

void TreeViewModelAdaptor::dump() const {
	if (!_model)
		return;
	int count = _items.count();
	if (count == 0)
		return;
	int countWidth = floor(log10(double(count))) + 1;
	qInfo() << "Dumping" << this;
	for (int i = 0; i < count; i++) {
		const TreeItem& item = _items.at(i);
		bool hasChildren = _model->hasChildren(item.index);
		int children = _model->rowCount(item.index);
		qInfo().noquote().nospace() << QString("%1 ").arg(i, countWidth) << QString(4 * item.depth, QChar::fromLatin1('.'))
																<< QLatin1String(!hasChildren ? ".. " : item.expanded ? " v " : " > ") << item.index
																<< children;
	}
}

bool TreeViewModelAdaptor::testConsistency(bool dumpOnFail) const {
	if (!_model) {
		if (!_items.isEmpty()) {
			qWarning() << "Model inconsistency: No model but stored visible items";
			return false;
		}
		if (!_expandedItems.isEmpty()) {
			qWarning() << "Model inconsistency: No model but stored expanded items";
			return false;
		}
		return true;
	}
	QModelIndex parent = _rootIndex;
	QStack<QModelIndex> ancestors;
	QModelIndex idx = _model->index(0, 0, parent);
	for (int i = 0; i < _items.count(); i++) {
		bool isConsistent = true;
		const TreeItem& item = _items.at(i);
		if (item.index != idx) {
			qWarning() << "QModelIndex inconsistency" << i << item.index;
			qWarning() << "    expected" << idx;
			isConsistent = false;
		}
		if (item.index.parent() != parent) {
			qWarning() << "Parent inconsistency" << i << item.index;
			qWarning() << "    stored index parent" << item.index.parent() << "model parent" << parent;
			isConsistent = false;
		}
		if (item.depth != ancestors.count()) {
			qWarning() << "Depth inconsistency" << i << item.index;
			qWarning() << "    item depth" << item.depth << "ancestors stack" << ancestors.count();
			isConsistent = false;
		}
		if (item.expanded && !_expandedItems.contains(item.index)) {
			qWarning() << "Expanded inconsistency" << i << item.index;
			qWarning() << "    set" << _expandedItems.contains(item.index) << "item" << item.expanded;
			isConsistent = false;
		}
		if (!isConsistent) {
			if (dumpOnFail) {
				dump();
			}
			return false;
		}
		QModelIndex firstChildIndex;
		if (item.expanded)
			firstChildIndex = _model->index(0, 0, idx);
		if (firstChildIndex.isValid()) {
			ancestors.push(parent);
			parent = idx;
			idx = _model->index(0, 0, parent);
		} else {
			while (idx.row() == _model->rowCount(parent) - 1) {
				if (ancestors.isEmpty())
					break;
				idx = parent;
				parent = ancestors.pop();
			}
			idx = _model->index(idx.row() + 1, 0, parent);
		}
	}

	return true;
}

void TreeViewModelAdaptor::enableSignalAggregation() {
	_signalAggregatorStack++;
}

void TreeViewModelAdaptor::disableSignalAggregation() {
	_signalAggregatorStack--;
	Q_ASSERT(_signalAggregatorStack >= 0);
	if (_signalAggregatorStack == 0) {
		emitQueuedSignals();
	}
}

inline bool TreeViewModelAdaptor::isAggregatingSignals() const {
	return _signalAggregatorStack > 0;
}

void TreeViewModelAdaptor::queueDataChanged(const QModelIndex& topLeft, const QModelIndex& bottomRight, const QVector<int>& roles) {
	if (isAggregatingSignals()) {
		_queuedDataChanged.append(DataChangedParams{ topLeft, bottomRight, roles });
	} else {
		emit dataChanged(topLeft, bottomRight, roles);
	}
}

void TreeViewModelAdaptor::emitQueuedSignals() {
	QVector<DataChangedParams> combinedUpdates;
	/* First, iterate through the queued updates and merge the overlapping ones
	 * to reduce the number of updates.
	 * We don't merge adjacent updates, because they are typically filed with a
	 * different role (a parent row is next to its children).
	 */
	for (const auto& dataChange : _queuedDataChanged) {
		auto startRow = dataChange.topLeft.row();
		auto endRow = dataChange.bottomRight.row();
		auto merged = false;
		for (auto& combined : combinedUpdates) {
			auto combinedStartRow = combined.topLeft.row();
			auto combinedEndRow = combined.bottomRight.row();
			if ((startRow <= combinedStartRow && endRow >= combinedStartRow) || (startRow <= combinedEndRow && endRow >= combinedEndRow)) {
				if (startRow < combinedStartRow) {
					combined.topLeft = dataChange.topLeft;
				}
				if (endRow > combinedEndRow) {
					combined.bottomRight = dataChange.bottomRight;
				}
				for (const auto& role : dataChange.roles) {
					if (!combined.roles.contains(role)) {
						combined.roles.append(role);
					}
				}
				merged = true;
				break;
			}
		}
		if (!merged) {
			combinedUpdates.append(dataChange);
		}
	}

	// Finally, emit the dataChanged signals.
	for (const auto& dataChange : combinedUpdates) {
		emit dataChanged(dataChange.topLeft, dataChange.bottomRight, dataChange.roles);
	}
	_queuedDataChanged.clear();
}
