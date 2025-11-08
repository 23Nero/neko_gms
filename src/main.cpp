#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QByteArray>
#include <QProcessEnvironment>
#include "devices/DeviceManager.h"

int main(int argc, char *argv[])
{
    qputenv("QML_XHR_ALLOW_FILE_READ", QByteArrayLiteral("1"));
    qputenv("QT_QUICK_CONTROLS_STYLE", QByteArrayLiteral("Basic"));

    QGuiApplication app(argc, argv);

    app.setWindowIcon(QIcon(":/qt/qml/neko_gms/ui/icon/avatar.png"));

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("deviceManager"), &DeviceManager::instance());
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("neko_gms", "Main");

    return app.exec();
}
