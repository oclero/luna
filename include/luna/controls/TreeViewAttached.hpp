#pragma once

#include <QtQuick/private/qquicktableview_p.h>

#include <QPointer>

namespace luna::controls {
class TreeViewTemplate;
class TreeViewTemplatePrivate;

class TreeViewAttached : public QQuickTableViewAttached {
	Q_OBJECT

	Q_PROPERTY(TreeViewTemplate* view READ view NOTIFY viewChanged)
	Q_PROPERTY(bool hasChildren READ hasChildren NOTIFY hasChildrenChanged)
	Q_PROPERTY(bool isExpanded READ isExpanded NOTIFY isExpandedChanged)
	Q_PROPERTY(int depth READ depth NOTIFY depthChanged)

public:
	TreeViewAttached(QObject* parent);
	TreeViewTemplate* view() const;

	bool hasChildren() const;
	void setHasChildren(bool hasChildren);

	bool isExpanded() const;
	void setIsExpanded(bool isExpanded);

	int depth() const;
	void setDepth(int depth);

signals:
	void viewChanged();
	void hasChildrenChanged();
	void isExpandedChanged();
	void depthChanged();

private:
	QPointer<TreeViewTemplate> _view;
	bool _hasChildren = false;
	bool _isExpanded = false;
	int _depth = -1;

	friend class TreeViewTemplatePrivate;
};
} // namespace luna::controls
