#include "devices/DeviceManager.h"

#include <QtDebug>
#include <QStringList>

#include "devices/DeviceService.h"

DeviceManager &DeviceManager::instance()
{
    static DeviceManager manager;
    return manager;
}

DeviceManager::DeviceManager()
    : QObject(nullptr)
    , m_service(std::make_unique<DeviceService>(this))
{
    m_statusMessage = tr("No device connected");
    m_deviceSummary = tr("Devices: 0");
}

DeviceManager::~DeviceManager() = default;

bool DeviceManager::busy() const
{
    return m_busy;
}

int DeviceManager::deviceCount() const
{
    return m_devices.size();
}

QVariantList DeviceManager::devices() const
{
    return m_devices;
}

QString DeviceManager::statusMessage() const
{
    return m_statusMessage;
}

QString DeviceManager::selectedDeviceId() const
{
    return m_selectedDeviceId;
}

QString DeviceManager::selectedDeviceName() const
{
    return m_selectedDevice.value(QStringLiteral("name")).toString();
}

QString DeviceManager::deviceSummary() const
{
    return m_deviceSummary;
}

void DeviceManager::requestDevices()
{
    if (m_busy)
    {
        return;
    }

    setBusy(true);
    m_statusMessage = tr("Scanning devices…");
    emit statusMessageChanged();

    m_service->fetchDevices(
        [this](const QList<DeviceInfo> &infos, const QList<DeviceError> &errors) {
            applyResult(infos, errors);
            setBusy(false);
        },
        [this](const DeviceError &error) {
            handleError(error);
            setBusy(false);
        });
}

void DeviceManager::setBusy(bool busy)
{
    if (m_busy == busy)
    {
        return;
    }

    m_busy = busy;
    emit busyChanged();
}

void DeviceManager::applyResult(const QList<DeviceInfo> &devices, const QList<DeviceError> &errors)
{
    QVariantList newDevices;
    QVariantMap firstDevice;
    QVariantMap matchedDevice;
    const QString previousSelection = m_selectedDeviceId;

    for (const DeviceInfo &info : devices)
    {
        QVariantMap map = info.toVariant();
        if (firstDevice.isEmpty())
        {
            firstDevice = map;
        }
        if (!previousSelection.isEmpty() && info.id == previousSelection)
        {
            matchedDevice = map;
        }
        newDevices.append(map);
    }

    m_devices = newDevices;

    emit devicesChanged();
    emit deviceListUpdated();

    if (!errors.isEmpty())
    {
        QStringList warningMessages;
        warningMessages.reserve(errors.size());
        for (const DeviceError &error : errors)
        {
            warningMessages.append(error.toString());
        }
        m_statusMessage = tr("Completed with warnings: %1").arg(warningMessages.join(QStringLiteral(", ")));
    }
    else if (m_devices.isEmpty())
    {
        m_statusMessage = tr("No device detected");
    }
    else if (m_devices.size() == 1)
    {
        const QVariantMap device = m_devices.constFirst().toMap();
        const QString name = device.value(QStringLiteral("name")).toString();
        m_statusMessage = tr("1 device connected (%1)").arg(name);
    }
    else
    {
        m_statusMessage = tr("%1 devices connected").arg(m_devices.size());
    }

    if (m_devices.isEmpty())
    {
        clearSelectedDevice();
    }
    else if (!matchedDevice.isEmpty())
    {
        setSelectedDeviceInternal(previousSelection, matchedDevice);
    }
    else if (!firstDevice.isEmpty())
    {
        setSelectedDeviceInternal(firstDevice.value(QStringLiteral("id")).toString(), firstDevice);
    }
    else
    {
        clearSelectedDevice();
    }

    emit statusMessageChanged();
}

void DeviceManager::handleError(const DeviceError &error)
{
    const QString message = error.toString().isEmpty() ? tr("Unable to query devices") : error.toString();
    m_statusMessage = message;
    emit statusMessageChanged();
    emit deviceQueryFailed(message);
    qWarning() << "Device query failed:" << message;
}

void DeviceManager::setSelectedDevice(const QString &deviceId)
{
    if (deviceId.isEmpty())
    {
        clearSelectedDevice();
        return;
    }

    for (const QVariant &entry : m_devices)
    {
        const QVariantMap device = entry.toMap();
        if (device.value(QStringLiteral("id")).toString() == deviceId)
        {
            setSelectedDeviceInternal(deviceId, device);
            return;
        }
    }
}

void DeviceManager::setSelectedDeviceInternal(const QString &deviceId, const QVariantMap &device)
{
    if (m_selectedDeviceId == deviceId && m_selectedDevice == device)
    {
        updateDeviceSummary();
        return;
    }

    m_selectedDeviceId = deviceId;
    m_selectedDevice = device;
    emit selectedDeviceChanged();
    updateDeviceSummary();
}

void DeviceManager::clearSelectedDevice()
{
    if (m_selectedDeviceId.isEmpty() && m_selectedDevice.isEmpty())
    {
        updateDeviceSummary();
        return;
    }

    m_selectedDeviceId.clear();
    m_selectedDevice.clear();
    emit selectedDeviceChanged();
    updateDeviceSummary();
}

void DeviceManager::updateDeviceSummary()
{
    QString summary;

    const int count = m_devices.size();
    if (count <= 0)
    {
        summary = tr("Devices: 0");
    }
    else if (m_selectedDeviceId.isEmpty())
    {
        summary = tr("Devices: %1 connected").arg(count);
    }
    else
    {
        const QString name = selectedDeviceName();
        const QString type = m_selectedDevice.value(QStringLiteral("type")).toString();
        if (type.isEmpty())
        {
            summary = tr("Devices: %1 (%2)").arg(count).arg(name);
        }
        else
        {
            summary = tr("Devices: %1 (%2 • %3)").arg(count).arg(name).arg(type);
        }
    }

    if (summary != m_deviceSummary)
    {
        m_deviceSummary = summary;
        emit deviceSummaryChanged();
    }
}
