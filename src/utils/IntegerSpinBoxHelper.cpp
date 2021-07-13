#include <luna/utils/IntegerSpinBoxHelper.hpp>

#include <QDebug>
#include <cassert>

namespace luna::utils {
IntegerSpinBoxHelper::IntegerSpinBoxHelper(QObject* parent)
	: QObject(parent) {
	_spinBox = qobject_cast<QQuickSpinBox*>(parent);
	assert(_spinBox);
	if (_spinBox) {
		QObject::connect(_spinBox, &QQuickSpinBox::valueChanged, this, &IntegerSpinBoxHelper::valueChanged);
	} else {
		qWarning() << "IntegerSpinBoxHelper can only be used on QQuickSpinBox";
	}
}

int IntegerSpinBoxHelper::value() const {
	return _spinBox ? _spinBox->value() : 0;
}

void IntegerSpinBoxHelper::setValue(const int value) {
	if (_spinBox) {
		_spinBox->setValue(value);
	}
}

IntegerSpinBoxHelper* IntegerSpinBoxHelper::qmlAttachedProperties(QObject* object) {
	return new IntegerSpinBoxHelper(object);
}
} // namespace luna::utils
