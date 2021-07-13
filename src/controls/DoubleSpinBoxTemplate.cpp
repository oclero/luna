#include <luna/controls/DoubleSpinBoxTemplate.hpp>

namespace luna::controls {
DoubleSpinBoxTemplate::DoubleSpinBoxTemplate(QQuickItem* parent)
	: QQuickItem(parent) {
	// We use the default locale:
	// - Decimal separator: point.
	// - Digit groups: no.
	_validator.setLocale(QLocale::c());

	// Prevent scientific notation.
	_validator.setNotation(QDoubleValidator::Notation::StandardNotation);

	// These values are independant of the actual range of the SpinBox.
	// They are only used to validate if the input text is a valid number.
	_validator.setBottom(-99999.9999);
	_validator.setTop(99999.9999);
	_validator.setDecimals(20);
}

qreal DoubleSpinBoxTemplate::value() const {
	return _value;
}

void DoubleSpinBoxTemplate::setValue(qreal value) {
	value = std::clamp(value, _from, _to);
	if (value != _value) {
		_value = value;
		emit valueChanged();
		emit valueAsTextChanged();
	}
}

void DoubleSpinBoxTemplate::modifyValue(qreal value) {
	const auto before = _value;
	setValue(value);
	const auto after = _value;
	if (before != after) {
		emit valueModified();
	} else {
		// Ensure text is synchronized even if the value hasn't changed.
		emit valueAsTextChanged();
	}
}

QString DoubleSpinBoxTemplate::valueAsText() const {
	return textFromValue(_value);
}

void DoubleSpinBoxTemplate::increase() {
	modifyValue(_value + _stepSize);
}

void DoubleSpinBoxTemplate::decrease() {
	modifyValue(_value - _stepSize);
}

qreal DoubleSpinBoxTemplate::from() const {
	return _from;
}

void DoubleSpinBoxTemplate::setFrom(qreal from) {
	if (from != _from) {
		_from = from;
		emit fromChanged();

		// Ensure _to is greater than _form.
		if (_to < _from) {
			_to = _from;
			emit toChanged();
		}

		// Ensure value is within range.
		const auto value = std::clamp(_value, _from, _to);
		if (_value != value) {
			_value = value;
			emit valueChanged();
		}
	}
}

qreal DoubleSpinBoxTemplate::to() const {
	return _to;
}

void DoubleSpinBoxTemplate::setTo(qreal to) {
	if (to != _to) {
		_to = to;
		emit toChanged();

		// Ensure _from is smaller than _to.
		if (_from > _to) {
			_from = _to;
			emit fromChanged();
		}

		// Ensure value is within range.
		const auto value = std::clamp(_value, _from, _to);
		if (_value != value) {
			_value = value;
			emit valueChanged();
		}
	}
}

qreal DoubleSpinBoxTemplate::stepSize() const {
	return _stepSize;
}

void DoubleSpinBoxTemplate::setStepSize(qreal stepSize) {
	if (stepSize != _stepSize) {
		_stepSize = stepSize;
		emit stepSizeChanged();
	}
}

int DoubleSpinBoxTemplate::decimals() const {
	return _decimals;
}

void DoubleSpinBoxTemplate::setDecimals(int decimals) {
	decimals = std::max(0, decimals);
	if (decimals != _decimals) {
		_decimals = decimals;
		emit decimalsChanged();
	}
}

bool DoubleSpinBoxTemplate::editable() const {
	return _editable;
}

void DoubleSpinBoxTemplate::setEditable(bool editable) {
	if (editable != _editable) {
		_editable = editable;
		emit editableChanged();
	}
}

QDoubleValidator* DoubleSpinBoxTemplate::validator() const {
	return &_validator;
}

const QString& DoubleSpinBoxTemplate::label() const {
	return _label;
}

void DoubleSpinBoxTemplate::setLabel(const QString& label) {
	if (label != _label) {
		_label = label;
		emit labelChanged();
	}
}

const QString& DoubleSpinBoxTemplate::unit() const {
	return _unit;
}

void DoubleSpinBoxTemplate::setUnit(const QString& unit) {
	if (unit != _unit) {
		_unit = unit;
		emit unitChanged();
	}
}

QString DoubleSpinBoxTemplate::textFromValue(const qreal value) const {
	return _locale.toString(value, 'f', _decimals).remove(_regex);
}

qreal DoubleSpinBoxTemplate::valueFromText(const QString& text) const {
	auto success{ false };
	auto result = _locale.toDouble(text, &success);
	if (!success) {
		result = _value;
	}
	return result;
}
} // namespace luna::controls
