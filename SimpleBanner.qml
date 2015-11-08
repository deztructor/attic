
import QtQuick 2.0
import Sailfish.Silica 1.0

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
