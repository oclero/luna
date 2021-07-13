#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <luna/QmlEngineConfig.hpp>
#include <luna/ResourceInitialization.hpp>

int main(int argc, char* argv[]) {
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
	QGuiApplication::setApplicationDisplayName("Luna example");
	QCoreApplication::setApplicationName("luna-example");
	QGuiApplication::setDesktopFileName("luna-example");
	QCoreApplication::setOrganizationName("Luna");
	QCoreApplication::setApplicationVersion("1.0.0");

	luna::initializeResources();

	QGuiApplication app(argc, argv);
	QQmlApplicationEngine engine;

	luna::registerQmlModule(engine);

	// Load main.qml file.
	const QUrl url(QStringLiteral("qrc:/main.qml"));
	QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &app, [url](QObject *obj, const QUrl &objUrl) {
		if (!obj && url == objUrl) {
			QCoreApplication::exit(-1);
		}
	}, Qt::QueuedConnection);
	engine.load(url);

	return app.exec();
}
