#pragma once

#include <QString>
#include <QVariantMap>

struct DeviceInfo
{
    QString id;
    QString name;
    QString type;
    QString status;
    QVariantMap extra;

    [[nodiscard]] QVariantMap toVariant() const
    {
        QVariantMap map;
        map.insert(QStringLiteral("id"), id);
        map.insert(QStringLiteral("name"), name);
        map.insert(QStringLiteral("type"), type);
        map.insert(QStringLiteral("status"), status);
        map.insert(QStringLiteral("extra"), extra);
        return map;
    }
};

struct DeviceError
{
    enum class Type
    {
        None,
        ProviderUnavailable,
        CommandFailed,
        Timeout,
        ParseError,
        Unknown
    };

    Type type = Type::None;
    QString provider;
    QString message;
    int exitCode = 0;

    [[nodiscard]] bool isError() const
    {
        return type != Type::None;
    }

    [[nodiscard]] QString toString() const
    {
        if (!isError())
        {
            return QString();
        }

        QString details = message;
        if (exitCode != 0)
        {
            details += QStringLiteral(" (code %1)").arg(exitCode);
        }
        if (!provider.isEmpty())
        {
            return QStringLiteral("%1: %2").arg(provider, details);
        }
        return details;
    }
};
