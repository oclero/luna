#pragma once

#include <QQuickItem>

namespace luna::utils {
class DragHandler : public QQuickItem {
	Q_OBJECT
	Q_PROPERTY(Qt::CursorShape cursorShape READ cursorShape WRITE setCursorShape NOTIFY cursorShapeChanged)
	Q_PROPERTY(bool pressed READ pressed NOTIFY pressedChanged)
	Q_PROPERTY(bool dragging READ dragging NOTIFY draggingChanged)
	Q_PROPERTY(QPoint startPoint READ startPoint NOTIFY startPointChanged)
	Q_PROPERTY(QPoint endPoint READ endPoint NOTIFY endPointChanged)

public:
	explicit DragHandler(QQuickItem* parent = nullptr);

	Qt::CursorShape cursorShape() const;
	void setCursorShape(const Qt::CursorShape cursorShape);

	bool pressed() const;
	bool dragging() const;
	const QPoint& startPoint() const;
	const QPoint& endPoint() const;

private:
	void setPressed(const bool pressed);
	void setDragging(const bool dragging);
	void setStartPoint(const QPoint& point);
	void setEndPoint(const QPoint& point);

	void start(const QPoint& point);
	void drag(const QPoint& point);
	void cancel();
	void stop(const QPoint& point);
	void finish(const QPoint& point);

protected:
	void mousePressEvent(QMouseEvent* event) override;
	void mouseMoveEvent(QMouseEvent* event) override;
	void mouseReleaseEvent(QMouseEvent* event) override;
	void keyPressEvent(QKeyEvent* event) override;
	void keyReleaseEvent(QKeyEvent* event) override;
	void itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData& value) override;
	bool eventFilter(QObject* obj, QEvent* evt) override;

signals:
	void cursorShapeChanged();
	void pressedChanged();
	void draggingChanged();
	void startPointChanged();
	void endPointChanged();
	void started();
	void finished();
	void canceled();
	void clicked();
	void dragged(int deltaX, int deltaY);

private:
	Qt::CursorShape _cursorShape{ Qt::CursorShape::SizeAllCursor };
	bool _pressed{ false };
	bool _dragging{ false };
	bool _canceled{ false };
	QPoint _startPointTemporary;
	QPoint _startPoint;
	QPoint _endPoint;
};
} // namespace luna::utils
