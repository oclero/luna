#pragma once

#include <QtQuick/private/qquicktableview_p_p.h>

#include <luna/controls/TreeViewAttached.hpp>
#include <luna/controls/TreeViewStyleHints.hpp>
#include <luna/controls/TreeViewTemplate.hpp>
#include "TreeViewModelAdaptor.hpp"

namespace luna::controls {
class TreeViewTemplatePrivate : public QQuickTableViewPrivate {
public:
	TreeViewTemplatePrivate(TreeViewTemplate& owner);
	~TreeViewTemplatePrivate() override;

	QVariant modelImpl() const override;
	void setModelImpl(const QVariant& newModel) override;
	void syncModel() override;

	QQuickItem* itemAtCell(const QPoint& cell) const;
	qreal effectiveRowHeight(int row) const;
	qreal effectiveColumnWidth(int column) const;

	void moveCurrentViewIndex(int directionX, int directionY);
	TreeViewAttached* getAttachedObject(const QObject* object) const;

	void initItemCallback(int modelIndex, QObject* object);
	void itemReusedCallback(int modelIndex, QObject* object);

	void checkForPropertyChanges();
	void updatePolish() override;

public:
	TreeViewTemplate& _owner;
	// QQuickTreeModelAdaptor1 basically takes a tree model and flattens
	// it into a list (which will be displayed in the first column of
	// the table). Each node in the tree can have several columns of
	// data in the model, which we show in the remaining columns of the table.
	TreeViewModelAdaptor _proxyModel;
	QVariant _assignedModel;
	QPersistentModelIndex _currentModelIndex;
	QModelIndex _currentModelIndexEmitted;
	QQuickItem* _currentItemEmitted = nullptr;
	QPointF _contentItemPosAtMousePress;
	TreeViewStyleHints _styleHints;
};
} // namespace luna::controls
