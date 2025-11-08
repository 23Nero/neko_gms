#pragma once

#include <QList>
#include <QString>

#include "devices/DeviceTypes.h"

class DeviceProvider
{
public:
    virtual ~DeviceProvider() = default;

    [[nodiscard]] virtual QString name() const = 0;
    virtual QList<DeviceInfo> collect(DeviceError &error) = 0;
};
