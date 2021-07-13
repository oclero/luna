#include <luna/utils/DragHandler.hpp>

#include <QQuickItem>
#include <QMouseEvent>
#include <QHoverEvent>
#include <QDebug>
#include <QGuiApplication>
#include <QCursor>
#include <QStyle>
#include <QStyleHints>

namespace luna::utils {
DragHandler::DragHandler(QQuickItem* parent)
	: QQuickItem(parent) {
	setAcceptedMouseButtons(Qt::LeftButton);
	setCursor({ _cursorShape });
	// Necessary to get the Escape keyEvent to cancel the drag.
	QGuiApplication::instance()->installEventFilter(this);
}

Qt::CursorShape DragHandler::cursorShape() const {
	return _cursorShape;
}

void DragHandler::setCursorShape(const Qt::CursorShape cursorShape) {
	if (cursorShape != _cursorShape) {
		_cursorShape = cursorShape;
		if (cursorShape == Qt::BlankCursor) {
			unsetCursor();
		} else {
			setCursor({ _cursorShape });
		}
		emit cursorShapeChanged();
	}
}

bool DragHandler::pressed() const {
	return _pressed;
}

void DragHandler::setPressed(const bool pressed) {
	if (pressed != _pressed) {
		_pressed = pressed;
		emit pressedChanged();
	}
}

bool DragHandler::dragging() const {
	return _dragging;
}

void DragHandler::setDragging(const bool dragging) {
	if (dragging != _dragging) {
		_dragging = dragging;
		emit draggingChanged();
	}
}

const QPoint& DragHandler::startPoint() const {
	return _startPoint;
}

void DragHandler::setStartPoint(const QPoint& point) {
	_startPoint = point;
	emit startPointChanged();
}

const QPoint& DragHandler::endPoint() const {
	return _endPoint;
}

void DragHandler::setEndPoint(const QPoint& point) {
	_endPoint = point;
	emit endPointChanged();
}

void DragHandler::start(const QPoint& point) {
	if (_dragging)
		return;

	_canceled = false;
	QGuiApplication::setOverrideCursor({ cursor().shape() });
	setKeepMouseGrab(true);
	setStartPoint(point);
	setDragging(true);

	emit started();
}

void DragHandler::drag(const QPoint& point) {
	if (!_dragging)
		return;

	const auto deltaX = _startPoint.x() - point.x();
	const auto deltaY = _startPoint.y() - point.y();
	emit dragged(deltaX, deltaY);
}

void DragHandler::stop(const QPoint& point) {
	if (!_dragging)
		return;

	QGuiApplication::restoreOverrideCursor();
	setPressed(false);
	setDragging(false);
	setEndPoint(point);
	setKeepMouseGrab(false);
}

void DragHandler::cancel() {
	if (!_dragging)
		return;

	_canceled = true;
	stop(_startPoint);
	emit canceled();
}

void DragHandler::finish(const QPoint& point) {
	if (!_dragging)
		return;

	_canceled = false;
	stop(point);
	emit finished();
}

void DragHandler::mousePressEvent(QMouseEvent* event) {
	QQuickItem::mousePressEvent(event);
	setPressed(true);
	_canceled = false;

	// Ignore event if we're currently dragging.
	if (_dragging) {
		event->ignore();
		return;
	}

	// If we don't accept the event, we won't receive mouseMove and and mouseRelease.
	event->accept();
	_startPointTemporary = event->localPos().toPoint();
}

void DragHandler::mouseMoveEvent(QMouseEvent* event) {
	QQuickItem::mouseMoveEvent(event);

	// Ignore event if mouse is not pressed.
	if (!_pressed || _canceled) {
		event->ignore();
		return;
	}

	const auto& point = event->localPos();

	// Start dragging when the distance is greater than the OS's min distance to start drag.
	if (!_dragging) {
		const auto hints = QGuiApplication::styleHints();
		const auto distance = (point - _startPointTemporary).manhattanLength();
		if (static_cast<int>(distance) < hints->startDragDistance()) {
			event->ignore();
			return;
		}

		event->accept();
		start(_startPointTemporary);
	}

	// If currently dragging, handle this new position.
	if (_dragging) {
		event->accept();
		drag(point.toPoint());
	}
}

void DragHandler::mouseReleaseEvent(QMouseEvent* event) {
	QQuickItem::mouseReleaseEvent(event);

	setPressed(false);
	const auto& point = event->localPos();
	// Ignore event if we weren't dragging.
	if (!_dragging && contains(point) && !_canceled) {
		event->ignore();
		// First, unset cursor to allow another widget to change the cursor.
		unsetCursor();
		emit clicked();
		// If we're still visible, we go back to our cursor.
		setCursor({ _cursorShape });
		return;
	}

	if (_dragging && !_canceled) {
		event->accept();
		finish(point.toPoint());
	}
}

void DragHandler::keyPressEvent(QKeyEvent* event) {
	QQuickItem::keyPressEvent(event);
	const auto key = event->key();
	if (key == Qt::Key_Escape) {
		event->accept();
		cancel();
	}
}

void DragHandler::keyReleaseEvent(QKeyEvent* event) {
	QQuickItem::keyReleaseEvent(event);
	const auto key = event->key();
	if (key == Qt::Key_Escape) {
		event->accept();
		cancel();
	}
}

void DragHandler::itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData& value) {
	QQuickItem::itemChange(change, value);

	if (change == QQuickItem::ItemChange::ItemEnabledHasChanged) {
		cancel();
	}
}

bool DragHandler::eventFilter(QObject* obj, QEvent* evt) {
	if (!_dragging)
		return false;

	const auto type = evt->type();
	switch (type) {
		case QEvent::KeyRelease:
		case QEvent::KeyPress: {
			const auto keyPressEvt = static_cast<QKeyEvent*>(evt);
			const auto key = keyPressEvt->key();
			if (key == Qt::Key_Escape) {
				evt->accept();
				cancel();
				return true;
			}
		} break;
		default:
			break;
	}
	return false;
}
} // namespace luna::utils
