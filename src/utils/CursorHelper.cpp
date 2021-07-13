#include <luna/utils/CursorHelper.hpp>

#include <QCursor>
#include <QGuiApplication>

namespace luna::utils {
CursorHelper::CursorHelper(QObject* parent)
	: QObject(parent) {}

CursorHelper::~CursorHelper() {
	QGuiApplication::restoreOverrideCursor();
}

Qt::CursorShape CursorHelper::cursor() const {
	return QGuiApplication::overrideCursor()->shape();
}

void CursorHelper::setCursor(const Qt::CursorShape cursor) {
	if (cursor != _cursor) {
		_cursor = cursor;

		// If the cursor is currently overriden, replace it by the new one.
		if (_overrideCursor) {
			QGuiApplication::changeOverrideCursor(QCursor{ _cursor });
		}

		emit cursorChanged();
	}
}

bool CursorHelper::overrideCursor() const {
	return _overrideCursor;
}

void CursorHelper::setOverrideCursor(const bool overrideCursor) {
	if (overrideCursor != _overrideCursor) {
		_overrideCursor = overrideCursor;

		// Do the actual cursor overriding.
		if (overrideCursor) {
			QGuiApplication::setOverrideCursor(QCursor{ _cursor });
		} else {
			QGuiApplication::restoreOverrideCursor();
		}

		emit overrideCursorChanged();
	}
}

CursorHelper* CursorHelper::qmlAttachedProperties(QObject* object) {
	return new CursorHelper(object);
}
} // namespace luna::utils
