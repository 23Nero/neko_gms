cmake_minimum_required(VERSION 3.16)

project(neko_gms VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Concurrent)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appneko_gms
    src/main.cpp
    include/devices/DeviceManager.h
    src/devices/DeviceManager.cpp
    include/devices/DeviceService.h
    src/devices/DeviceService.cpp
    include/devices/DeviceTypes.h
    include/devices/providers/DeviceProvider.h
    include/devices/providers/AdbDeviceProvider.h
    src/devices/providers/AdbDeviceProvider.cpp
    include/devices/providers/UsbDeviceProvider.h
    src/devices/providers/UsbDeviceProvider.cpp
)

qt_add_qml_module(appneko_gms
    URI neko_gms
    VERSION 1.0
    QML_FILES
        ui/Main.qml
        ui/LogView.qml
        ui/FilterPanel.qml
        ui/HeaderToolbar.qml
        ui/StatusBar.qml
        ui/components/DevicePicker.qml
        ui/log_patterns/index.js
    RESOURCES
        ui/icon/avatar.png
        ui/logs/test.log
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appneko_gms PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appneko_gms
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appneko_gms
    PRIVATE Qt6::Quick
    PRIVATE Qt6::Concurrent
)

target_include_directories(appneko_gms
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)

include(GNUInstallDirs)
install(TARGETS appneko_gms
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
