#pragma once

#include <qqml.h>
#include <QObject>

namespace luna::utils {
class CursorHelper : public QObject {
	Q_OBJECT
	Q_PROPERTY(bool overrideCursor READ overrideCursor WRITE setOverrideCursor NOTIFY overrideCursorChanged)
	Q_PROPERTY(Qt::CursorShape cursor READ cursor WRITE setCursor NOTIFY cursorChanged)

public:
	explicit CursorHelper(QObject* parent = nullptr);
	~CursorHelper();

	bool overrideCursor() const;
	void setOverrideCursor(const bool overrideCursor);

	Qt::CursorShape cursor() const;
	void setCursor(const Qt::CursorShape cursor);

	static CursorHelper* qmlAttachedProperties(QObject* object);

signals:
	void overrideCursorChanged();
	void cursorChanged();

private:
	bool _overrideCursor{ false };
	Qt::CursorShape _cursor{ Qt::CursorShape::ArrowCursor };
};
} // namespace luna::utils

QML_DECLARE_TYPEINFO(luna::utils::CursorHelper, QML_HAS_ATTACHED_PROPERTIES)
