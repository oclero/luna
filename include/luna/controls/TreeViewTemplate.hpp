#pragma once

#include <QAbstractItemModel>
#include <QtQuick/private/qquicktableview_p.h>

#include <luna/controls/TreeViewStyleHints.hpp>
#include <luna/controls/TreeViewAttached.hpp>

#include <QPointer>

namespace luna::controls {
class TreeViewTemplatePrivate;

class TreeViewTemplate : public QQuickTableView {
	Q_OBJECT

	Q_PROPERTY(QModelIndex currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged);
	Q_PROPERTY(QModelIndex currentModelIndex READ currentModelIndex WRITE setCurrentModelIndex NOTIFY currentModelIndexChanged);
	Q_PROPERTY(QQuickItem* currentItem READ currentItem NOTIFY currentItemChanged);
	Q_PROPERTY(luna::controls::TreeViewStyleHints* styleHints READ styleHints CONSTANT);

	QML_ATTACHED(TreeViewAttached)

public:
	TreeViewTemplate(QQuickItem* parent = nullptr);
	~TreeViewTemplate() override;

	Q_INVOKABLE bool hasChildren(int row) const;
	Q_INVOKABLE bool hasSiblings(int row) const;
	Q_INVOKABLE int depth(int row) const;

	Q_INVOKABLE bool isExpanded(int row) const;
	Q_INVOKABLE void expand(int row);
	Q_INVOKABLE void collapse(int row);
	Q_INVOKABLE void toggleExpanded(int row);

	Q_INVOKABLE bool isModelIndexExpanded(const QModelIndex& modelIndex) const;
	Q_INVOKABLE void collapseModelIndex(const QModelIndex& modelIndex);
	Q_INVOKABLE void expandModelIndex(const QModelIndex& modelIndex);
	Q_INVOKABLE void toggleModelIndexExpanded(const QModelIndex& modelIndex);

	Q_INVOKABLE int columnAtX(int x, bool includeSpacing) const;
	Q_INVOKABLE int rowAtY(int y, bool includeSpacing) const;

	Q_INVOKABLE QQuickItem* itemAtCell(const QPoint& cell) const;
	Q_INVOKABLE QQuickItem* itemAtIndex(const QModelIndex& viewIndex) const;
	Q_INVOKABLE QQuickItem* itemAtModelIndex(const QModelIndex& modelIndex) const;

	Q_INVOKABLE QModelIndex viewIndex(int column, int row) const;
	Q_INVOKABLE QModelIndex mapToModel(const QModelIndex& viewIndex) const;
	Q_INVOKABLE QModelIndex mapFromModel(const QModelIndex& modelIndex) const;

	QModelIndex currentIndex() const;
	void setCurrentIndex(const QModelIndex& index);
	QQuickItem* currentItem() const;

	QModelIndex currentModelIndex() const;
	void setCurrentModelIndex(const QModelIndex& modelIndex);

	TreeViewStyleHints* styleHints() const;

	static TreeViewAttached* qmlAttachedProperties(QObject* obj);

protected:
	void viewportMoved(Qt::Orientations orientation) override;
	void keyPressEvent(QKeyEvent* e) override;
	void mousePressEvent(QMouseEvent* e) override;
	void mouseReleaseEvent(QMouseEvent* e) override;
	void mouseDoubleClickEvent(QMouseEvent* e) override;

signals:
	void currentIndexChanged();
	void currentModelIndexChanged();
	void expanded(int row);
	void collapsed(int row);
	void currentItemChanged();

private:
	Q_DISABLE_COPY(TreeViewTemplate)
	Q_DECLARE_PRIVATE(TreeViewTemplate)

	TreeViewTemplatePrivate* _impl{ nullptr };
};
} // namespace luna::controls
