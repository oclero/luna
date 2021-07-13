#include <luna/controls/IntegerSpinBoxTemplate.hpp>

namespace luna::controls {
IntegerSpinBoxTemplate::IntegerSpinBoxTemplate(QQuickItem* parent)
	: QQuickItem(parent) {
	// We use the default locale:
	// - Digit groups: no.
	_validator.setLocale(QLocale::c());

	// These values are independant of the actual range of the SpinBox.
	// They are only used to validate if the input text is a valid number.
	_validator.setRange(-999999, 999999);
}

int IntegerSpinBoxTemplate::value() const {
	return _value;
}

void IntegerSpinBoxTemplate::setValue(int value) {
	value = std::clamp(value, _from, _to);
	if (value != _value) {
		_value = value;
		emit valueChanged();
		emit valueAsTextChanged();
	}
}

void IntegerSpinBoxTemplate::modifyValue(int value) {
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

QString IntegerSpinBoxTemplate::valueAsText() const {
	return textFromValue(_value);
}

void IntegerSpinBoxTemplate::increase() {
	modifyValue(_value + _stepSize);
}

void IntegerSpinBoxTemplate::decrease() {
	modifyValue(_value - _stepSize);
}

int IntegerSpinBoxTemplate::from() const {
	return _from;
}

void IntegerSpinBoxTemplate::setFrom(int from) {
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

int IntegerSpinBoxTemplate::to() const {
	return _to;
}

void IntegerSpinBoxTemplate::setTo(int to) {
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

int IntegerSpinBoxTemplate::stepSize() const {
	return _stepSize;
}

void IntegerSpinBoxTemplate::setStepSize(int stepSize) {
	if (stepSize != _stepSize) {
		_stepSize = stepSize;
		emit stepSizeChanged();
	}
}

bool IntegerSpinBoxTemplate::editable() const {
	return _editable;
}

void IntegerSpinBoxTemplate::setEditable(bool editable) {
	if (editable != _editable) {
		_editable = editable;
		emit editableChanged();
	}
}

QIntValidator* IntegerSpinBoxTemplate::validator() const {
	return &_validator;
}

const QString& IntegerSpinBoxTemplate::label() const {
	return _label;
}

void IntegerSpinBoxTemplate::setLabel(const QString& label) {
	if (label != _label) {
		_label = label;
		emit labelChanged();
	}
}

const QString& IntegerSpinBoxTemplate::unit() const {
	return _unit;
}

void IntegerSpinBoxTemplate::setUnit(const QString& unit) {
	if (unit != _unit) {
		_unit = unit;
		emit unitChanged();
	}
}

QString IntegerSpinBoxTemplate::textFromValue(const int value) const {
	return _locale.toString(value);
}

int IntegerSpinBoxTemplate::valueFromText(const QString& text) const {
	auto success{ false };
	auto result = _locale.toInt(text, &success);
	if (!success) {
		result = _value;
	}
	return result;
}
} // namespace luna::controls
