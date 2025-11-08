#include "devices/providers/AdbDeviceProvider.h"

#include <QProcess>
#include <QStringList>
#include <QtGlobal>

QString AdbDeviceProvider::name() const
{
    return QStringLiteral("ADB");
}

QList<DeviceInfo> AdbDeviceProvider::collect(DeviceError &error)
{
    error = DeviceError{};

    QProcess process;
    process.start(QStringLiteral("adb"), {QStringLiteral("devices"), QStringLiteral("-l")});

    if (!process.waitForStarted(3000))
    {
        error.type = DeviceError::Type::ProviderUnavailable;
        error.provider = name();
        error.message = QStringLiteral("Failed to start adb process");
        return {};
    }

    if (!process.waitForFinished(5000))
    {
        process.kill();
        error.type = DeviceError::Type::Timeout;
        error.provider = name();
        error.message = QStringLiteral("adb timed out while listing devices");
        return {};
    }

    if (process.exitStatus() != QProcess::NormalExit)
    {
        error.type = DeviceError::Type::CommandFailed;
        error.provider = name();
        error.message = QStringLiteral("adb exited abnormally");
        return {};
    }

    if (process.exitCode() != 0)
    {
        error.type = DeviceError::Type::CommandFailed;
        error.provider = name();
        error.message = QStringLiteral("adb returned a non-zero exit code");
        error.exitCode = process.exitCode();
        return {};
    }

    const QString output = QString::fromUtf8(process.readAllStandardOutput());
    const QStringList lines = output.split(QLatin1Char('\n'), Qt::SkipEmptyParts);

    QList<DeviceInfo> devices = parseOutput(lines);
    if (devices.isEmpty())
    {
        // No devices is a valid state, keep error empty.
        return devices;
    }

    return devices;
}

QList<DeviceInfo> AdbDeviceProvider::parseOutput(const QStringList &lines) const
{
    QList<DeviceInfo> devices;
    QRegularExpression whitespace(QStringLiteral("\\s+"));

    for (const QString &line : lines)
    {
        const QString trimmed = line.trimmed();
        if (trimmed.isEmpty())
        {
            continue;
        }
        if (trimmed.startsWith(QLatin1String("List of devices"), Qt::CaseInsensitive))
        {
            continue;
        }
        if (trimmed.startsWith(QLatin1Char('*')))
        {
            // Ignore informational lines such as "* daemon not running".
            continue;
        }

        QStringList tokens = trimmed.split(whitespace, Qt::SkipEmptyParts);
        if (tokens.isEmpty())
        {
            continue;
        }

        DeviceInfo info;
        info.id = tokens.takeFirst();
        info.type = QStringLiteral("adb");
        info.status = tokens.isEmpty() ? QStringLiteral("unknown") : tokens.takeFirst();

        QVariantMap extra;
        int detailCounter = 0;
        for (const QString &token : tokens)
        {
            const int separatorIndex = token.indexOf(QLatin1Char(':'));
            if (separatorIndex > 0)
            {
                const QString key = token.left(separatorIndex);
                const QString value = token.mid(separatorIndex + 1);
                extra.insert(key, value);
            }
            else
            {
                // Preserve any remaining information.
                extra.insert(QStringLiteral("detail%1").arg(++detailCounter), token);
            }
        }

        info.name = extra.value(QStringLiteral("model"), info.id).toString();
        info.extra = extra;
        devices.append(info);
    }

    return devices;
}
