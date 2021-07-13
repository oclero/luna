#pragma once

#include <QObject>
#include <QQuickItem>
#include <QString>
#include <QLocale>
#include <QIntValidator>
#include <QRegularExpression>

namespace luna::controls {
/**
 * @brief Allows to create a QML SpinBox that handles integer values.
 */
class IntegerSpinBoxTemplate : public QQuickItem {
	Q_OBJECT

	Q_PROPERTY(int value READ value WRITE setValue NOTIFY valueChanged)
	Q_PROPERTY(QString valueAsText READ valueAsText NOTIFY valueAsTextChanged)
	Q_PROPERTY(int from READ from WRITE setFrom NOTIFY fromChanged)
	Q_PROPERTY(int to READ to WRITE setTo NOTIFY toChanged)
	Q_PROPERTY(int stepSize READ stepSize WRITE setStepSize NOTIFY stepSizeChanged)
	Q_PROPERTY(bool editable READ editable WRITE setEditable NOTIFY editableChanged)
	Q_PROPERTY(QIntValidator* validator READ validator NOTIFY validatorChanged)
	Q_PROPERTY(QString label READ label WRITE setLabel NOTIFY labelChanged)
	Q_PROPERTY(QString unit READ unit WRITE setUnit NOTIFY unitChanged)

public:
	IntegerSpinBoxTemplate(QQuickItem* parent = nullptr);

	int value() const;
	void setValue(int value);
	Q_SIGNAL void valueChanged();

	QString valueAsText() const;
	Q_SIGNAL void valueAsTextChanged();

	int from() const;
	void setFrom(int from);
	Q_SIGNAL void fromChanged();

	int to() const;
	void setTo(int to);
	Q_SIGNAL void toChanged();

	int stepSize() const;
	void setStepSize(int stepSize);
	Q_SIGNAL void stepSizeChanged();

	int decimals() const;
	void setDecimals(int decimals);
	Q_SIGNAL void decimalsChanged();

	bool editable() const;
	void setEditable(bool editable);
	Q_SIGNAL void editableChanged();

	QIntValidator* validator() const;
	Q_SIGNAL void validatorChanged();

	const QString& label() const;
	void setLabel(const QString& label);
	Q_SIGNAL void labelChanged();

	const QString& unit() const;
	void setUnit(const QString& label);
	Q_SIGNAL void unitChanged();

	/**
	 * @brief Call this if the value change comes from user interaction. Will emit valueModied().
	 */
	Q_SLOT void modifyValue(int value);

	/**
	 * @brief From user interaction, adds 1 step to value. Will emit valueModied().
	 */
	Q_SLOT void increase();

	/**
	 * @brief From user interaction, removes 1 step to value. Will emit valueModied().
	 */
	Q_SLOT void decrease();

	/**
	 * @brief Emitted when the value has been changed from user interaction.
	 */
	Q_SIGNAL void valueModified();

	Q_SLOT QString textFromValue(const int value) const;
	Q_SLOT int valueFromText(const QString& text) const;

private:
	const QLocale _locale{ QLocale::c() };
	mutable QIntValidator _validator;
	int _value{ 0 };
	int _from{ 0 };
	int _to{ 10 };
	int _stepSize{ 1 };
	bool _editable{ false };
	QString _label;
	QString _unit;
};
} // namespace luna::controls
