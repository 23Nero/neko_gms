#include "devices/DeviceService.h"

#include <QFutureWatcher>
#include <QtConcurrent>
#include <QtDebug>

#include "devices/providers/AdbDeviceProvider.h"
#include "devices/providers/DeviceProvider.h"
#include "devices/providers/UsbDeviceProvider.h"

DeviceService::DeviceService(QObject *parent)
    : QObject(parent)
{
    m_providers.emplace_back(std::make_unique<AdbDeviceProvider>());
    m_providers.emplace_back(std::make_unique<UsbDeviceProvider>());
}

DeviceService::~DeviceService() = default;

void DeviceService::fetchDevices(SuccessCallback onSuccess, ErrorCallback onError)
{
    auto watcher = new QFutureWatcher<FetchResult>(this);

    connect(
        watcher,
        &QFutureWatcher<FetchResult>::finished,
        this,
        [watcher, onSuccess = std::move(onSuccess), onError = std::move(onError)]() mutable {
            const FetchResult result = watcher->future().result();
            watcher->deleteLater();

            if (result.success)
            {
                if (onSuccess)
                {
                    onSuccess(result.devices, result.providerErrors);
                }
            }
            else
            {
                if (onError)
                {
                    if (!result.providerErrors.isEmpty())
                    {
                        onError(result.providerErrors.constFirst());
                    }
                    else
                    {
                        DeviceError fallback;
                        fallback.type = DeviceError::Type::Unknown;
                        fallback.provider = QStringLiteral("Service");
                        fallback.message = QObject::tr("Failed to gather device information");
                        onError(fallback);
                    }
                }
            }
        });

    watcher->setFuture(QtConcurrent::run([this]() { return collectFromProviders(); }));
}

DeviceService::FetchResult DeviceService::collectFromProviders() const
{
    FetchResult result;
    bool anySuccess = false;

    for (const auto &provider : m_providers)
    {
        if (!provider)
        {
            continue;
        }

        DeviceError providerError;
        QList<DeviceInfo> providerDevices = provider->collect(providerError);
        if (providerError.isError())
        {
            result.providerErrors.append(providerError);
            qWarning() << "Provider" << provider->name() << "failed:" << providerError.toString();
            continue;
        }

        anySuccess = true;
        for (const DeviceInfo &info : providerDevices)
        {
            result.devices.append(info);
        }
    }

    result.success = anySuccess;
    return result;
}
