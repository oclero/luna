#include "TreeViewTemplatePrivate.hpp"

namespace luna::controls {
TreeViewTemplatePrivate::TreeViewTemplatePrivate(TreeViewTemplate& owner)
	: _owner(owner) {}

TreeViewTemplatePrivate::~TreeViewTemplatePrivate() = default;

QVariant TreeViewTemplatePrivate::modelImpl() const {
	return _assignedModel;
}

void TreeViewTemplatePrivate::setModelImpl(const QVariant& newModel) {
	if (newModel == _assignedModel)
		return;

	_assignedModel = newModel;
	QVariant effectiveModel = _assignedModel;
	if (effectiveModel.userType() == qMetaTypeId<QJSValue>()) {
		effectiveModel = effectiveModel.value<QJSValue>().toVariant();
	}

	if (effectiveModel.isNull()) {
		_proxyModel.setModel(nullptr);
	} else if (const auto qaim = qvariant_cast<QAbstractItemModel*>(effectiveModel)) {
		_proxyModel.setModel(qaim);
	} else {
		qmlWarning(&_owner) << "TreeView only accepts models of type QAbstractItemModel";
	}

	scheduleRebuildTable(QQuickTableViewPrivate::RebuildOption::All);
	emit _owner.modelChanged();
}

void TreeViewTemplatePrivate::syncModel() {
	if (model) {
		QObjectPrivate::disconnect(model, &QQmlInstanceModel::initItem, this, &TreeViewTemplatePrivate::initItemCallback);
		QObjectPrivate::disconnect(model, &QQmlInstanceModel::itemReused, this, &TreeViewTemplatePrivate::itemReusedCallback);
	}

	QQuickTableViewPrivate::syncModel();

	if (model) {
		QObjectPrivate::connect(model, &QQmlInstanceModel::initItem, this, &TreeViewTemplatePrivate::initItemCallback);
		QObjectPrivate::connect(model, &QQmlInstanceModel::itemReused, this, &TreeViewTemplatePrivate::itemReusedCallback);
	}
}

TreeViewAttached* TreeViewTemplatePrivate::getAttachedObject(const QObject* object) const {
	QObject* attachedObject = qmlAttachedPropertiesObject<TreeViewTemplate>(object);
	return static_cast<TreeViewAttached*>(attachedObject);
}

void TreeViewTemplatePrivate::initItemCallback(int modelIndex, QObject* object) {
	Q_UNUSED(modelIndex);

	if (auto attached = getAttachedObject(object)) {
		const auto context = qmlContext(object);
		const auto row = context->contextProperty(QStringLiteral("row")).toInt();
		attached->setIsExpanded(_owner.isExpanded(row));
		attached->setHasChildren(_owner.hasChildren(row));
		attached->setDepth(_proxyModel.depthAtRow(row));
	}
}

void TreeViewTemplatePrivate::itemReusedCallback(int modelIndex, QObject* object) {
	Q_UNUSED(modelIndex);

	if (auto attached = getAttachedObject(object)) {
		const auto context = qmlContext(object);
		const auto row = context->contextProperty(QStringLiteral("row")).toInt();
		attached->setIsExpanded(_owner.isExpanded(row));
		attached->setHasChildren(_owner.hasChildren(row));
		attached->setDepth(_proxyModel.depthAtRow(row));
	}
}

void TreeViewTemplatePrivate::updatePolish() {
	QQuickTableViewPrivate::updatePolish();
	if (loadRequest.isActive()) {
		return;
	}

	checkForPropertyChanges();
}

void TreeViewTemplatePrivate::checkForPropertyChanges() {
	if (_currentModelIndexEmitted != _currentModelIndex) {
		// m_currentIndex is a QPersistentModelIndex which will update automatically, so
		// we need this extra detour to check if is has changed after a model change.
		_currentModelIndexEmitted = _currentModelIndex;
		emit _owner.currentIndexChanged();
		emit _owner.currentModelIndexChanged();
	}

	QQuickItem* currentItem = _owner.currentItem();
	if (_currentItemEmitted != currentItem) {
		// Because QQuickTableView shuffles and reuse items, we need to check each time
		// after a rebuild if currentItem has changed, and not trust that this only changes
		// when m_currentViewIndex changes.
		_currentItemEmitted = currentItem;
		emit _owner.currentItemChanged();
	}
}

QQuickItem* TreeViewTemplatePrivate::itemAtCell(const QPoint& cell) const {
	// Copied from qquicktableview in Qt6.
	const auto modelIndex = modelIndexAtCell(cell);
	if (!loadedItems.contains(modelIndex)) {
		return nullptr;
	}
	return loadedItems.value(modelIndex)->item;
}

qreal TreeViewTemplatePrivate::effectiveRowHeight(int row) const {
	// Copied from qquicktableview in Qt6.
	return loadedTableItem(QPoint(leftColumn(), row))->geometry().height();
}

qreal TreeViewTemplatePrivate::effectiveColumnWidth(int column) const {
	// Copied from qquicktableview in Qt6.
	return loadedTableItem(QPoint(column, topRow()))->geometry().width();
}

void TreeViewTemplatePrivate::moveCurrentViewIndex(int directionX, int directionY) {
	const auto oldViewIndex = _owner.mapFromModel(_currentModelIndex);
	const auto row = qBound(0, oldViewIndex.row() + directionY, _owner.rows() - 1);
	const auto column = qBound(0, oldViewIndex.column() + directionX, _owner.columns() - 1);
	const auto newViewIndex = _owner.viewIndex(column, row);
	_owner.setCurrentModelIndex(_owner.mapToModel(newViewIndex));

	// Move the current item into the viewport so that it loads
	if (column < leftColumn()) {
		_owner.setContentX(_owner.contentX() - cellSpacing.width() - 1);
	} else if (column > rightColumn()) {
		_owner.setContentX(_owner.contentX() + cellSpacing.width() + 1);
	}

	if (row < topRow()) {
		_owner.setContentY(_owner.contentY() - cellSpacing.height() - 1);
	} else if (row > bottomRow()) {
		_owner.setContentY(_owner.contentY() + cellSpacing.height() + 1);
	}

	if (auto* item = _owner.currentItem()) {
		// Ensure that the whole item is visible
		const auto itemRect = QRectF(_owner.mapFromItem(_owner.contentItem(), item->position()), item->size());

		if (itemRect.x() <= 0) {
			_owner.setContentX(item->x());
		} else if (itemRect.right() > _owner.size().width()) {
			_owner.setContentX(item->x() + item->width() - _owner.width());
		}

		if (itemRect.y() <= 0) {
			_owner.setContentY(item->y());
		} else if (itemRect.bottom() > _owner.size().height()) {
			_owner.setContentY(item->y() + item->height() - _owner.height());
		}
	}
}
} // namespace luna::controls
