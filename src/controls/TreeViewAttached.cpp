#include <luna/controls/TreeViewAttached.hpp>
#include <luna/controls/TreeViewTemplate.hpp>

namespace luna::controls {
TreeViewAttached::TreeViewAttached(QObject* parent)
	: QQuickTableViewAttached(parent) {}

TreeViewTemplate* TreeViewAttached::view() const {
	return _view;
}

bool TreeViewAttached::hasChildren() const {
	return _hasChildren;
}

void TreeViewAttached::setHasChildren(bool hasChildren) {
	if (_hasChildren == hasChildren)
		return;

	_hasChildren = hasChildren;
	emit hasChildrenChanged();
}

bool TreeViewAttached::isExpanded() const {
	return _isExpanded;
}

void TreeViewAttached::setIsExpanded(bool isExpanded) {
	if (_isExpanded == isExpanded)
		return;

	_isExpanded = isExpanded;
	emit isExpandedChanged();
}

int TreeViewAttached::depth() const {
	return _depth;
}

void TreeViewAttached::setDepth(int depth) {
	if (_depth == depth)
		return;

	_depth = depth;
	emit depthChanged();
}
} // namespace luna::controls
