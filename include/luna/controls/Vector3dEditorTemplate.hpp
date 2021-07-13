#pragma once

#include <QQuickItem>
#include <QVector3D>

namespace luna::controls {
/**
 * @brief Allows to edit the 3 values of a QVector3D.
 */
class Vector3dEditorTemplate : public QQuickItem {
	Q_OBJECT

	Q_PROPERTY(QVector3D value READ value WRITE setValue NOTIFY valueChanged)
	Q_PROPERTY(float x READ x WRITE setX NOTIFY xChanged)
	Q_PROPERTY(float y READ y WRITE setY NOTIFY yChanged)
	Q_PROPERTY(float z READ z WRITE setZ NOTIFY zChanged)
	Q_PROPERTY(float from READ from WRITE setFrom NOTIFY fromChanged)
	Q_PROPERTY(float to READ to WRITE setTo NOTIFY toChanged)
	Q_PROPERTY(float stepSize READ stepSize WRITE setStepSize NOTIFY stepSizeChanged)
	Q_PROPERTY(int decimals READ decimals WRITE setDecimals NOTIFY decimalsChanged)

public:
	Vector3dEditorTemplate(QQuickItem* parent = nullptr);

	const QVector3D& value() const;
	void setValue(const QVector3D& value);
	Q_SIGNAL void valueChanged();
	Q_SLOT void modifyValue(const QVector3D& value);
	Q_SIGNAL void valueModified();

	float x() const;
	void setX(float x);
	Q_SIGNAL void xChanged();
	Q_SLOT void modifyX(float x);
	Q_SIGNAL void xModified();

	float y() const;
	void setY(float y);
	Q_SIGNAL void yChanged();
	Q_SLOT void modifyY(float y);
	Q_SIGNAL void yModified();

	float z() const;
	void setZ(float z);
	Q_SIGNAL void zChanged();
	Q_SLOT void modifyZ(float z);
	Q_SIGNAL void zModified();

	float from() const;
	void setFrom(float from);
	Q_SIGNAL void fromChanged();

	float to() const;
	void setTo(float to);
	Q_SIGNAL void toChanged();

	float stepSize() const;
	void setStepSize(float stepSize);
	Q_SIGNAL void stepSizeChanged();

	int decimals() const;
	void setDecimals(int decimals);
	Q_SIGNAL void decimalsChanged();

private:
	QVector3D _value{ 0.f, 0.f, 0.f };
	float _from{ 0.f };
	float _to{ 1.f };
	float _stepSize{ 0.1f };
	int _decimals{ 3 };
};
} // namespace luna::controls
