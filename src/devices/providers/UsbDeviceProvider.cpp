#include "devices/providers/UsbDeviceProvider.h"

#include <QStorageInfo>

QString UsbDeviceProvider::name() const
{
    return QStringLiteral("USB");
}

QList<DeviceInfo> UsbDeviceProvider::collect(DeviceError &error)
{
    error = DeviceError{};

    QList<DeviceInfo> devices;
    const QList<QStorageInfo> volumes = QStorageInfo::mountedVolumes();
    for (const QStorageInfo &volume : volumes)
    {
        if (!volume.isValid() || !volume.isReady())
        {
            continue;
        }

        const QByteArray deviceId = volume.device().toLower();
        const bool looksLikeUsb = deviceId.contains("usb") || deviceId.contains("removable");
        const QString rootPath = volume.rootPath();
        const bool isSystemDrive = rootPath.startsWith(QStringLiteral("C:"), Qt::CaseInsensitive);
        if (!looksLikeUsb && isSystemDrive)
        {
            continue;
        }

        DeviceInfo info;
        info.id = QString::fromUtf8(volume.device());
        info.name = volume.displayName();
        if (info.name.isEmpty())
        {
            info.name = volume.rootPath();
        }
        info.type = QStringLiteral("usb-storage");
        info.status = QStringLiteral("ready");

        QVariantMap extra;
        extra.insert(QStringLiteral("rootPath"), volume.rootPath());
        extra.insert(QStringLiteral("bytesTotal"), static_cast<qlonglong>(volume.bytesTotal()));
        extra.insert(QStringLiteral("bytesAvailable"), static_cast<qlonglong>(volume.bytesAvailable()));
        extra.insert(QStringLiteral("filesystem"), volume.fileSystemType());
        info.extra = extra;

        devices.append(info);
    }

    return devices;
}
