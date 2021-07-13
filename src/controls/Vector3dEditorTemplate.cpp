#include <luna/controls/Vector3dEditorTemplate.hpp>

namespace luna::controls {
Vector3dEditorTemplate::Vector3dEditorTemplate(QQuickItem* parent)
	: QQuickItem(parent) {}

const QVector3D& Vector3dEditorTemplate::value() const {
	return _value;
}

void Vector3dEditorTemplate::setValue(const QVector3D& value) {
	const auto newValue = QVector3D{
		std::clamp(value.x(), _from, _to),
		std::clamp(value.y(), _from, _to),
		std::clamp(value.z(), _from, _to),
	};
	if (newValue != _value) {
		_value = newValue;
		emit valueChanged();

		// Don't bother with checking if each value has changed.
		emit xChanged();
		emit yChanged();
		emit zChanged();
	}
}

void Vector3dEditorTemplate::modifyValue(const QVector3D& value) {
	const auto before = _value;
	setValue(value);
	const auto& after = _value;
	if (before != after) {
		emit valueModified();
	}
}

float Vector3dEditorTemplate::x() const {
	return _value.x();
}

void Vector3dEditorTemplate::setX(float x) {
	x = std::clamp(x, _from, _to);
	if (x != _value.x()) {
		_value.setX(x);
		emit xChanged();
		emit valueChanged();
	}
}

void Vector3dEditorTemplate::modifyX(float x) {
	const auto before = _value.x();
	setX(x);
	const auto after = _value.x();
	if (before != after) {
		emit xModified();
		emit valueModified();
	}
}

float Vector3dEditorTemplate::y() const {
	return _value.y();
}

void Vector3dEditorTemplate::setY(float y) {
	y = std::clamp(y, _from, _to);
	if (y != _value.y()) {
		_value.setY(y);
		emit yChanged();
		emit valueChanged();
	}
}

void Vector3dEditorTemplate::modifyY(float y) {
	const auto before = _value.y();
	setY(y);
	const auto after = _value.y();
	if (before != after) {
		emit yModified();
		emit valueModified();
	}
}

float Vector3dEditorTemplate::z() const {
	return _value.z();
}

void Vector3dEditorTemplate::setZ(float z) {
	z = std::clamp(z, _from, _to);
	if (z != _value.z()) {
		_value.setZ(z);
		emit zChanged();
		emit valueChanged();
	}
}

void Vector3dEditorTemplate::modifyZ(float z) {
	const auto before = _value.z();
	setZ(z);
	const auto after = _value.z();
	if (before != after) {
		emit zModified();
		emit valueModified();
	}
}


float Vector3dEditorTemplate::from() const {
	return _from;
}

void Vector3dEditorTemplate::setFrom(float from) {
	if (from != _from) {
		_from = from;
		emit fromChanged();

		// Ensure _to is greater than _form.
		if (_to < _from) {
			_to = _from;
			emit toChanged();
		}

		// Ensure value is within range.
		const auto newValue = QVector3D{
			std::clamp(_value.x(), _from, _to),
			std::clamp(_value.y(), _from, _to),
			std::clamp(_value.z(), _from, _to),
		};
		if (_value != newValue) {
			_value = newValue;
			emit valueChanged();
		}
	}
}

float Vector3dEditorTemplate::to() const {
	return _to;
}

void Vector3dEditorTemplate::setTo(float to) {
	if (to != _to) {
		_to = to;
		emit toChanged();

		// Ensure _from is smaller than _to.
		if (_from > _to) {
			_from = _to;
			emit fromChanged();
		}

		// Ensure value is within range.
		const auto newValue = QVector3D{
			std::clamp(_value.x(), _from, _to),
			std::clamp(_value.y(), _from, _to),
			std::clamp(_value.z(), _from, _to),
		};
		if (_value != newValue) {
			_value = newValue;
			emit valueChanged();
		}
	}
}

float Vector3dEditorTemplate::stepSize() const {
	return _stepSize;
}

void Vector3dEditorTemplate::setStepSize(float stepSize) {
	if (stepSize != _stepSize) {
		_stepSize = stepSize;
		emit stepSizeChanged();
	}
}

int Vector3dEditorTemplate::decimals() const {
	return _decimals;
}

void Vector3dEditorTemplate::setDecimals(int decimals) {
	decimals = std::max(0, decimals);
	if (decimals != _decimals) {
		_decimals = decimals;
		emit decimalsChanged();
	}
}
} // namespace luna::controls
