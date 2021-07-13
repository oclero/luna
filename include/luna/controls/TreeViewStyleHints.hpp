#pragma once

#include <QObject>
#include <QColor>

namespace luna::controls {
class TreeViewStyleHints : public QObject {
	Q_OBJECT

	Q_PROPERTY(QColor arrowColor MEMBER _arrowColor NOTIFY arrowColorChanged);
	Q_PROPERTY(QColor arrowHoveredColor MEMBER _arrowHoveredColor NOTIFY arrowHoveredColorChanged);
	Q_PROPERTY(QColor arrowSelectedColor MEMBER _arrowSelectedColor NOTIFY arrowSelectedColorChanged);
	Q_PROPERTY(QColor arrowDisabledColor MEMBER _arrowDisabledColor NOTIFY arrowDisabledColorChanged);

	Q_PROPERTY(QColor textColor MEMBER _textColor NOTIFY textColorChanged);
	Q_PROPERTY(QColor textHoveredColor MEMBER _textHoveredColor NOTIFY textHoveredColorChanged);
	Q_PROPERTY(QColor textSelectedColor MEMBER _textSelectedColor NOTIFY textSelectedColorChanged);
	Q_PROPERTY(QColor textDisabledColor MEMBER _textDisabledColor NOTIFY textDisabledColorChanged);

	Q_PROPERTY(QColor secondaryTextColor MEMBER _secondaryTextColor NOTIFY secondaryTextColorChanged);
	Q_PROPERTY(QColor secondaryTextHoveredColor MEMBER _secondaryTextHoveredColor NOTIFY secondaryTextHoveredColorChanged);
	Q_PROPERTY(QColor secondaryTextSelectedColor MEMBER _secondaryTextSelectedColor NOTIFY secondaryTextSelectedColorChanged);
	Q_PROPERTY(QColor secondaryTextDisabledColor MEMBER _secondaryTextDisabledColor NOTIFY secondaryTextDisabledColorChanged);

	Q_PROPERTY(QColor backgroundEvenColor MEMBER _backgroundEvenColor NOTIFY backgroundEvenColorChanged);
	Q_PROPERTY(QColor backgroundOddColor MEMBER _backgroundOddColor NOTIFY backgroundOddColorChanged);
	Q_PROPERTY(QColor backgroundHoveredColor MEMBER _backgroundHoveredColor NOTIFY backgroundHoveredColorChanged);
	Q_PROPERTY(QColor backgroundSelectedColor MEMBER _backgroundSelectedColor NOTIFY backgroundSelectedColorChanged);
	Q_PROPERTY(QColor backgroundDisabledColor MEMBER _backgroundDisabledColor NOTIFY backgroundDisabledColorChanged);

signals:
	void arrowColorChanged();
	void arrowHoveredColorChanged();
	void arrowSelectedColorChanged();
	void arrowDisabledColorChanged();

	void textColorChanged();
	void textHoveredColorChanged();
	void textSelectedColorChanged();
	void textDisabledColorChanged();

	void secondaryTextColorChanged();
	void secondaryTextHoveredColorChanged();
	void secondaryTextSelectedColorChanged();
	void secondaryTextDisabledColorChanged();

	void backgroundEvenColorChanged();
	void backgroundOddColorChanged();
	void backgroundHoveredColorChanged();
	void backgroundSelectedColorChanged();
	void backgroundDisabledColorChanged();

private:
	QColor _arrowColor{ Qt::black };
	QColor _arrowHoveredColor{ Qt::white };
	QColor _arrowSelectedColor{ Qt::white };
	QColor _arrowDisabledColor{ Qt::lightGray };

	QColor _textColor{ Qt::black };
	QColor _textHoveredColor{ Qt::white };
	QColor _textSelectedColor{ Qt::white };
	QColor _textDisabledColor{ Qt::lightGray };

	QColor _secondaryTextColor{ Qt::gray };
	QColor _secondaryTextHoveredColor{ Qt::white };
	QColor _secondaryTextSelectedColor{ Qt::white };
	QColor _secondaryTextDisabledColor{ Qt::lightGray };;

	QColor _backgroundEvenColor{ Qt::white };
	QColor _backgroundOddColor{ 245, 245, 245};
	QColor _backgroundHoveredColor{ 35, 115, 220 };
	QColor _backgroundSelectedColor{ 35, 115, 220 };
	QColor _backgroundDisabledColor{ Qt::transparent };
};
} // namespace luna::controls
