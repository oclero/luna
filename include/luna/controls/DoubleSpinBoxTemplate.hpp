#pragma once

#include <QObject>
#include <QQuickItem>
#include <QString>
#include <QLocale>
#include <QDoubleValidator>
#include <QRegularExpression>

namespace luna::controls {
/**
 * @brief Allows to create a QML SpinBox that handles floating point values.
 */
class DoubleSpinBoxTemplate : public QQuickItem {
	Q_OBJECT

	Q_PROPERTY(qreal value READ value WRITE setValue NOTIFY valueChanged)
	Q_PROPERTY(QString valueAsText READ valueAsText NOTIFY valueAsTextChanged)
	Q_PROPERTY(qreal from READ from WRITE setFrom NOTIFY fromChanged)
	Q_PROPERTY(qreal to READ to WRITE setTo NOTIFY toChanged)
	Q_PROPERTY(qreal stepSize READ stepSize WRITE setStepSize NOTIFY stepSizeChanged)
	Q_PROPERTY(int decimals READ decimals WRITE setDecimals NOTIFY decimalsChanged)
	Q_PROPERTY(bool editable READ editable WRITE setEditable NOTIFY editableChanged)
	Q_PROPERTY(QDoubleValidator* validator READ validator NOTIFY validatorChanged)
	Q_PROPERTY(QString label READ label WRITE setLabel NOTIFY labelChanged)
	Q_PROPERTY(QString unit READ unit WRITE setUnit NOTIFY unitChanged)

public:
	DoubleSpinBoxTemplate(QQuickItem* parent = nullptr);

	qreal value() const;
	void setValue(qreal value);
	Q_SIGNAL void valueChanged();

	QString valueAsText() const;
	Q_SIGNAL void valueAsTextChanged();

	qreal from() const;
	void setFrom(qreal from);
	Q_SIGNAL void fromChanged();

	qreal to() const;
	void setTo(qreal to);
	Q_SIGNAL void toChanged();

	qreal stepSize() const;
	void setStepSize(qreal stepSize);
	Q_SIGNAL void stepSizeChanged();

	int decimals() const;
	void setDecimals(int decimals);
	Q_SIGNAL void decimalsChanged();

	bool editable() const;
	void setEditable(bool editable);
	Q_SIGNAL void editableChanged();

	QDoubleValidator* validator() const;
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
	Q_SLOT void modifyValue(qreal value);

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

	Q_SLOT QString textFromValue(const qreal value) const;
	Q_SLOT qreal valueFromText(const QString& text) const;

private:
	const QLocale _locale{ QLocale::c() };
	// Regex to remove trailing zeros.
	const QRegularExpression _regex{ QStringLiteral("\\%1?0+$").arg(_locale.decimalPoint()) };
	mutable QDoubleValidator _validator;
	qreal _value{ 0. };
	qreal _from{ 0. };
	qreal _to{ 1. };
	qreal _stepSize{ 0.1 };
	bool _editable{ false };
	int _decimals{ 3 };
	QString _label;
	QString _unit;
};
} // namespace luna::controls
