#pragma once

#include <QSet>
#include <QPointer>
#include <QAbstractItemModel>
#include <QItemSelectionModel>
#include <QPersistentModelIndex>

class TreeViewModelAdaptor : public QAbstractItemModel {
	Q_OBJECT
	Q_PROPERTY(QAbstractItemModel* model READ model WRITE setModel NOTIFY modelChanged)
	Q_PROPERTY(QModelIndex rootIndex READ rootIndex WRITE setRootIndex RESET resetRootIndex NOTIFY rootIndexChanged)

	struct TreeItem;

public:
	explicit TreeViewModelAdaptor(QObject* parent = nullptr);

	QAbstractItemModel* model() const;
	const QModelIndex& rootIndex() const;
	void setRootIndex(const QModelIndex& idx);
	void resetRootIndex();

	QModelIndex index(int row, int column, const QModelIndex& parent = QModelIndex()) const;
	QModelIndex parent(const QModelIndex& child) const;

	int rowCount(const QModelIndex& parent = QModelIndex()) const;
	int columnCount(const QModelIndex& parent = QModelIndex()) const;

	enum {
		DepthRole = Qt::UserRole - 5,
		ExpandedRole,
		HasChildrenRole,
		HasSiblingRole,
		ModelIndexRole,
	};

	QHash<int, QByteArray> roleNames() const;
	QVariant data(const QModelIndex&, int role) const;
	bool setData(const QModelIndex& index, const QVariant& value, int role);
	QVariant headerData(int section, Qt::Orientation orientation, int role) const;

	void clearModelData();

	bool isVisible(const QModelIndex& index);
	bool childrenVisible(const QModelIndex& index);

	QModelIndex mapToModel(const QModelIndex& index) const;
	QModelIndex mapFromModel(const QModelIndex& index) const;
	QModelIndex mapToModel(int row) const;

	Q_INVOKABLE QItemSelection selectionForRowRange(const QModelIndex& fromIndex, const QModelIndex& toIndex) const;

	void showModelTopLevelItems(bool doInsertRows = true);
	void showModelChildItems(
		const TreeItem& parent, int start, int end, bool doInsertRows = true, bool doExpandPendingRows = true);

	int itemIndex(const QModelIndex& index) const;
	void expandPendingRows(bool doInsertRows = true);
	int lastChildIndex(const QModelIndex& index);
	void removeVisibleRows(int startIndex, int endIndex, bool doRemoveRows = true);

	void dump() const;
	bool testConsistency(bool dumpOnFail = false) const;

	using QAbstractItemModel::hasChildren;

signals:
	void modelChanged(QAbstractItemModel* model);
	void rootIndexChanged();
	void expanded(const QModelIndex& index);
	void collapsed(const QModelIndex& index);

public slots:
	void expand(const QModelIndex&);
	void collapse(const QModelIndex&);
	void setModel(QAbstractItemModel* model);
	bool isExpanded(const QModelIndex&) const;
	bool isExpanded(int row) const;
	bool hasChildren(int row) const;
	bool hasSiblings(int row) const;
	int depthAtRow(int row) const;
	void expandRow(int n);
	void collapseRow(int n);

private slots:
	void modelHasBeenDestroyed();
	void modelHasBeenReset();
	void modelDataChanged(const QModelIndex& topLeft, const QModelIndex& bottomRigth, const QVector<int>& roles);
	void modelLayoutAboutToBeChanged(
		const QList<QPersistentModelIndex>& parents, QAbstractItemModel::LayoutChangeHint hint);
	void modelLayoutChanged(const QList<QPersistentModelIndex>& parents, QAbstractItemModel::LayoutChangeHint hint);
	void modelRowsAboutToBeInserted(const QModelIndex& parent, int start, int end);
	void modelRowsAboutToBeMoved(const QModelIndex& sourceParent, int sourceStart, int sourceEnd,
		const QModelIndex& destinationParent, int destinationRow);
	void modelRowsAboutToBeRemoved(const QModelIndex& parent, int start, int end);
	void modelRowsInserted(const QModelIndex& parent, int start, int end);
	void modelRowsMoved(const QModelIndex& sourceParent, int sourceStart, int sourceEnd,
		const QModelIndex& destinationParent, int destinationRow);
	void modelRowsRemoved(const QModelIndex& parent, int start, int end);

private:
	struct TreeItem {
		QPersistentModelIndex index;
		int depth;
		bool expanded;

		explicit TreeItem(const QModelIndex& idx = {}, int d = 0, int e = false)
			: index(idx)
			, depth(d)
			, expanded(e) {}

		inline bool operator==(const TreeItem& other) const {
			return this->index == other.index;
		}
	};

	struct DataChangedParams {
		QModelIndex topLeft;
		QModelIndex bottomRight;
		QVector<int> roles;
	};

	struct SignalFreezer {
		SignalFreezer(TreeViewModelAdaptor* parent)
			: parent(parent) {
			parent->enableSignalAggregation();
		}

		~SignalFreezer() {
			parent->disableSignalAggregation();
		}

	private:
		TreeViewModelAdaptor* parent;
	};

	void enableSignalAggregation();
	void disableSignalAggregation();
	bool isAggregatingSignals() const;
	void queueDataChanged(const QModelIndex& topLeft, const QModelIndex& bottomRight, const QVector<int>& roles);
	void emitQueuedSignals();

	QPointer<QAbstractItemModel> _model = nullptr;
	QPersistentModelIndex _rootIndex;
	QList<TreeItem> _items;
	QSet<QPersistentModelIndex> _expandedItems;
	QList<TreeItem*> _itemsToExpand;
	mutable int _lastItemIndex = 0;
	bool _visibleRowsMoved = false;
	int _signalAggregatorStack = 0;
	QVector<DataChangedParams> _queuedDataChanged;
	int _column = 0;
};
