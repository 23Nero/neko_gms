#pragma once

#include <functional>
#include <memory>
#include <vector>

#include <QObject>

#include "devices/DeviceTypes.h"
#include "devices/providers/DeviceProvider.h"

class DeviceService : public QObject
{
    Q_OBJECT

public:
    using SuccessCallback = std::function<void(const QList<DeviceInfo> &, const QList<DeviceError> &)>;
    using ErrorCallback = std::function<void(const DeviceError &)>;

    explicit DeviceService(QObject *parent = nullptr);
    ~DeviceService() override;

    void fetchDevices(SuccessCallback onSuccess, ErrorCallback onError);

private:
    struct FetchResult
    {
        bool success = false;
        QList<DeviceInfo> devices;
        QList<DeviceError> providerErrors;
    };

    [[nodiscard]] FetchResult collectFromProviders() const;

    std::vector<std::unique_ptr<DeviceProvider>> m_providers;
};
