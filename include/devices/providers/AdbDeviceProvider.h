#pragma once

#include <QRegularExpression>
#include <QString>

#include "devices/providers/DeviceProvider.h"

class AdbDeviceProvider final : public DeviceProvider
{
public:
    [[nodiscard]] QString name() const override;
    QList<DeviceInfo> collect(DeviceError &error) override;

private:
    [[nodiscard]] QList<DeviceInfo> parseOutput(const QStringList &lines) const;
};
