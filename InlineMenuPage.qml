import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    property bool rightHanded: false
    property real indicatorPadding: Theme.paddingMedium
    SilicaListView {
        anchors.fill: parent

        delegate: MouseArea {
            id: listItem
            readonly property real baseHeight: Theme.itemSizeMedium
            height: baseHeight
            readonly property real dHeight: height - baseHeight
            width: ListView.view.width
            readonly property int maxHeight: menuColumn.childrenRect.height

            property real dragStartX: 0
            property real dragX: 0
            property real dx: rightHanded ? dragStartX - dragX : dragX - dragStartX
            property real dragXMax: Theme.itemSizeMedium

            property real span: state === "opening" ? Math.min(dx / dragXMax, 1.0) : 0.0
            
            property real dragStartY: 0
            property alias dragY: menuColumn.dragY
            
            property InlineMenuItem currentMenuItem
            property real selectionY: currentMenuItem
                ? currentMenuItem.y + currentMenuItem.height / 2
                : 0

            preventStealing: state === "opening"
            state: "initial"
            onStateChanged: console.log("State", state)
            states: [
                State {
                    name: "initial"
                    PropertyChanges { target: listItem; height: listItem.baseHeight }
                    PropertyChanges { target: listItem; dragStartX: 0 }
                    PropertyChanges { target: listItem; dragX: 0 }
                    PropertyChanges { target: listItem; dragStartY: 0 }
                    PropertyChanges { target: listItem; dragY: 0 }
                    //PropertyChanges { target: listItem; preventStealing: false }
                    PropertyChanges { target: listItem; currentMenuItem: null }
                }
                , State {
                    name: "detecting"
                    PropertyChanges { target: listItem; height: listItem.baseHeight }
                }
            ]
            Label {
                id: targetItem
                width: parent.width
                height: baseHeight
                text: model.name
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            Item  {
                id: menuIndicator
                width: Theme.itemSizeMedium
                height: baseHeight
                readonly property real maxWidth: listItem.width - indicatorPadding
                
                x: rightHanded ? (maxWidth - width) : indicatorPadding

                Rectangle {
                    id: menuArea
                    x: rightHanded ? menuIndicator.width - width : 0
                    width: listItem.span
                        ? Math.max(menuIndicator.maxWidth * listItem.span, menuIndicator.width)
                        : parent.width
                    onWidthChanged: console.log("W from", listItem.span)
                    height: listItem.height
                    color: "black"
                    opacity: 0.2
                }
                Item {
                    height: menuIndicator.height
                    width: menuArea.width
                    x: menuArea.x
                    y: listItem.selectionY ? listItem.selectionY - height / 2 : 0
                    Item {
                        id: menuIcon
                        height: parent.height
                        width: height
                        Image {
                            readonly property string expandIcon: "image://theme/icon-m-"
                                + (rightHanded ? "left" : "right")
                            readonly property string selectIcon: "image://theme/icon-m-"
                                + (rightHanded ? "right" : "left")
                            readonly property string hintImage: "image://theme/icon-m-down"
                            source: listItem.selectionY
                                ? selectIcon : (span < 0.9 ? expandIcon : hintImage)
                            anchors.centerIn: parent
                            opacity: listItem.state !== "initial" ? 1.0 : 0.2
                        }
                    }
                    Rectangle {
                        opacity: listItem.selectionY ? 0.5 : 0.0
                        x: menuIcon.width
                        height: Theme.paddingLarge
                        width: parent.width - menuIcon.width
                        anchors.verticalCenter: parent.verticalCenter
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: Theme.rgba(Theme.primaryColor, 0.1) }
                            GradientStop { position: 0.5; color: Theme.rgba(Theme.primaryColor, 0.2) }
                            GradientStop { position: 1.0; color: Theme.rgba(Theme.primaryColor, 0.1) }
                        }
                    }
                }
            }
            Column {
                id: menuColumn
                width: parent.width
                height: parent.height
                clip: true
                property real dragY: 0
                state: parent.state
                Item {
                    width: 1
                    height: targetItem.height
                }
                InlineMenuItem {
                    text: "Menu 1"
                    onClicked: {
                        console.log("Menu 1")
                        banner.show(text + " clicked for " + model.name)
                    }
                }
                InlineMenuItem {
                    text: "Menu 2"
                    onClicked: {
                        console.log("Menu 2")
                        banner.show(text + " clicked for " + model.name)
                    }
                }
            }
            onPressed: {
                console.log("P", mouse.y, dragY)
                if (mouse.x >= menuIndicator.x && mouse.x <= menuIndicator.x + menuIndicator.height) {
                    state = "detecting"
                    dragStartX = mouse.x
                    dragStartY = mouse.y
                    dragY = dragStartY
                }
            }
            function resetState() {
                console.log("resetState")
                // currentMenuItem = null
                // preventStealing = false
                state = "initial"
                console.log("reseted", currentMenuItem)
            }
            onReleased: {
                var defered = function() {}
                if (state === "opening" && currentMenuItem) {
                    console.log("Do Click")
                    defered = currentMenuItem.clicked
                }
                resetState()
                defered()
            }
            onCanceled: {
                resetState()
            }
            onPositionChanged : {
                dragX = mouse.x
                var dy = mouse.y - dragStartY
                if (state === "detecting") {
                    if (dy > listItem.height / 2) {
                        state = "initial"
                    } else if (dx > listItem.height / 4) {
                        //preventStealing = true
                        state = "opening"
                    }
                }
                if (state === "opening") {
                    if (currentMenuItem && (mouse.y < baseHeight
                                            || mouse.y > maxHeight)) {
                        currentMenuItem = null
                    }
                    var menuDY = maxHeight ? maxHeight * span : 0
                    height = Math.max(baseHeight, Math.min(baseHeight + menuDY, maxHeight))
                    dragY = mouse.y
                }
            }
        }
        model: snapshots
    }
    Rectangle {
        id: banner
        width: parent.width - Theme.itemSizeMedium
        height: Theme.itemSizeLarge
        anchors.centerIn: parent
        opacity: 0
        Behavior on opacity { FadeAnimation {} }
        color: "black"
        Label {
            id: bannerLabel
            anchors.centerIn: parent
        }
        function show(text) {
            bannerLabel.text = text
            opacity = 0.7
            bannerTimer.running = true
        }
        Timer {
            id: bannerTimer
            interval: 1000
            onTriggered: banner.opacity = 0
        }
    }
    ListModel {
        id: snapshots
        ListElement { name: "8250_pci.h" }
        ListElement { name: "a1026.h" }
        ListElement { name: "acct.h" }
        ListElement { name: "acpi_dma.h" }
        ListElement { name: "acpi_gpio.h" }
        ListElement { name: "acpi.h" }
        ListElement { name: "acpi_io.h" }
        ListElement { name: "acpi_pmtmr.h" }
        ListElement { name: "adb.h" }
        ListElement { name: "adfs_fs.h" }
        ListElement { name: "aer.h" }
        ListElement { name: "agp_backend.h" }
        ListElement { name: "agpgart.h" }
        ListElement { name: "ahci_platform.h" }
        ListElement { name: "aio.h" }
        ListElement { name: "alarmtimer.h" }
        ListElement { name: "altera_jtaguart.h" }
        ListElement { name: "altera_uart.h" }
        ListElement { name: "amba" }
        ListElement { name: "amd-iommu.h" }
        ListElement { name: "amifd.h" }
        ListElement { name: "wakelock.h" }
        ListElement { name: "wanrouter.h" }
        ListElement { name: "watchdog.h" }
        ListElement { name: "wifi_tiwlan.h" }
        ListElement { name: "wimax" }
        ListElement { name: "wireless.h" }
        ListElement { name: "wl12xx.h" }
        ListElement { name: "wlan_plat.h" }
        ListElement { name: "wm97xx.h" }
        ListElement { name: "workqueue.h" }
        ListElement { name: "writeback.h" }
        ListElement { name: "ww_mutex.h" }
        ListElement { name: "xattr.h" }
        ListElement { name: "xilinxfb.h" }
        ListElement { name: "xz.h" }
        ListElement { name: "yam.h" }
        ListElement { name: "z2_battery.h" }
        ListElement { name: "zconf.h" }
        ListElement { name: "zlib.h" }
        ListElement { name: "zorro.h" }
        ListElement { name: "zorro_ids.h" }
        ListElement { name: "zutil.h" }
    }
}
