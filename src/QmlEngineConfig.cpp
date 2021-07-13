#include <luna/QmlEngineConfig.hpp>

#include <luna/controls/IntegerSpinBoxTemplate.hpp>
#include <luna/controls/DoubleSpinBoxTemplate.hpp>
#include <luna/controls/TreeViewTemplate.hpp>
#include <luna/controls/TreeViewStyleHints.hpp>
#include <luna/controls/Vector3dEditorTemplate.hpp>
#include <luna/utils/CursorHelper.hpp>
#include <luna/utils/DragHandler.hpp>
#include <luna/utils/IntegerSpinBoxHelper.hpp>

#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFontDatabase>

namespace luna {
// Makes these types available in QML.
void registerQmlTypes() {
	static const QString QML_CREATION_NOT_ALLOWED = QStringLiteral("Type creation is not allowed from QML.");
	static const QString QML_ONLY_AS_ATTACHED_TYPE = QStringLiteral("Type only available as an attached type.");

	{
		// QML Templates.
		constexpr auto uri = "Luna.Templates";
		using namespace controls;
		qmlRegisterType<DoubleSpinBoxTemplate>(uri, 1, 0, "DoubleSpinBox");
		qmlRegisterType<IntegerSpinBoxTemplate>(uri, 1, 0, "IntegerSpinBox");
		qmlRegisterType<TreeViewTemplate>(uri, 1, 0, "TreeView");
		qmlRegisterUncreatableType<TreeViewStyleHints>(uri, 1, 0, "TreeViewStyleHints", QML_CREATION_NOT_ALLOWED);
		qmlRegisterType<Vector3dEditorTemplate>(uri, 1, 0, "Vector3dEditorTemplate");
	}
	{
		// QML Utilities
		constexpr auto uri = "Luna.QmlUtils";
		using namespace utils;
		qmlRegisterUncreatableType<CursorHelper>(uri, 1, 0, "CursorHelper", QML_ONLY_AS_ATTACHED_TYPE);
		qmlRegisterType<DragHandler>(uri, 1, 0, "DragHandler");
		qmlRegisterUncreatableType<IntegerSpinBoxHelper>(uri, 1, 0, "IntegerSpinBoxHelper", QML_ONLY_AS_ATTACHED_TYPE);
	}
}

// Registers default system fonts to QML because they are not available by default.
void registerAliasesForSystemFonts(QQmlContext* qmlContext) {
	qmlContext->setContextProperty(QStringLiteral("$monospaceFont"), QFontDatabase::systemFont(QFontDatabase::FixedFont));
	qmlContext->setContextProperty(QStringLiteral("$defaultFont"), QFontDatabase::systemFont(QFontDatabase::GeneralFont));
}

void registerQmlModule(QQmlApplicationEngine& qml) {
	// Declare all necessary C++ types to QML.
	registerQmlTypes();

	// Add custom QML modules to be imported.
	qml.addImportPath(QStringLiteral("qrc:/luna/qml"));

	// Register globally-available objects for QML.
	const auto qmlContext = qml.rootContext();
	registerAliasesForSystemFonts(qmlContext);
}
} // namespace luna
