#pragma once

#include "devices/providers/DeviceProvider.h"

class UsbDeviceProvider final : public DeviceProvider
{
public:
    [[nodiscard]] QString name() const override;
    QList<DeviceInfo> collect(DeviceError &error) override;
};
