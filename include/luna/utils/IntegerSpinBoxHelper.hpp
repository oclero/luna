#pragma once

#include <qqml.h>
#include <QtQuickTemplates2/private/qquickspinbox_p.h>

namespace luna::utils {
/**
 * @brief This class is avaiable as an attached object on QtQuick items.
 * When attached specifically on a QQuickSpinBox, it allows us to change the
 * QQuickSpinBox's value without breaking the potentially existing binding(s).
 * It just serves as a proxy to circumvent QML's internal property bindings mecanisms.
 */
class IntegerSpinBoxHelper : public QObject {
	Q_OBJECT
	Q_PROPERTY(int value READ value WRITE setValue NOTIFY valueChanged)

public:
	explicit IntegerSpinBoxHelper(QObject* parent = nullptr);

	int value() const;
	void setValue(const int value);

	static IntegerSpinBoxHelper* qmlAttachedProperties(QObject* object);

signals:
	void valueChanged();

private:
	QQuickSpinBox* _spinBox{ nullptr };
};
} // namespace luna::utils

QML_DECLARE_TYPEINFO(luna::utils::IntegerSpinBoxHelper, QML_HAS_ATTACHED_PROPERTIES)
