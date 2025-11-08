#pragma once

#include <memory>

#include <QObject>
#include <QVariantList>

#include "devices/DeviceTypes.h"

class DeviceService;

class DeviceManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged FINAL)
    Q_PROPERTY(int deviceCount READ deviceCount NOTIFY devicesChanged FINAL)
    Q_PROPERTY(QVariantList devices READ devices NOTIFY devicesChanged FINAL)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged FINAL)
    Q_PROPERTY(QString selectedDeviceId READ selectedDeviceId NOTIFY selectedDeviceChanged FINAL)
    Q_PROPERTY(QString selectedDeviceName READ selectedDeviceName NOTIFY selectedDeviceChanged FINAL)
    Q_PROPERTY(QString deviceSummary READ deviceSummary NOTIFY deviceSummaryChanged FINAL)

public:
    static DeviceManager &instance();

    [[nodiscard]] bool busy() const;
    [[nodiscard]] int deviceCount() const;
    [[nodiscard]] QVariantList devices() const;
    [[nodiscard]] QString statusMessage() const;
    [[nodiscard]] QString selectedDeviceId() const;
    [[nodiscard]] QString selectedDeviceName() const;
    [[nodiscard]] QString deviceSummary() const;

    Q_INVOKABLE void requestDevices();
    Q_INVOKABLE void setSelectedDevice(const QString &deviceId);

signals:
    void busyChanged();
    void devicesChanged();
    void statusMessageChanged();
    void deviceListUpdated();
    void deviceQueryFailed(const QString &message);
    void selectedDeviceChanged();
    void deviceSummaryChanged();

private:
    DeviceManager();
    ~DeviceManager() override;

    void setBusy(bool busy);
    void applyResult(const QList<DeviceInfo> &devices, const QList<DeviceError> &errors);
    void handleError(const DeviceError &error);
    void setSelectedDeviceInternal(const QString &deviceId, const QVariantMap &device);
    void clearSelectedDevice();
    void updateDeviceSummary();

    bool m_busy = false;
    QVariantList m_devices;
    QString m_statusMessage;
    std::unique_ptr<DeviceService> m_service;
    QString m_selectedDeviceId;
    QVariantMap m_selectedDevice;
    QString m_deviceSummary;
};
