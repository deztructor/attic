import QtQuick 2.0
import Sailfish.Silica 1.0

ApplicationWindow {
    id: mainWindow
    initialPage: Page {
        MouseArea {
            x : 0
            width: parent.width / 2
            height: parent.height
            onClicked: pageStack.push("InlineMenuPage.qml", {rightHanded: false})
            Rectangle {
                anchors.fill: parent
                opacity: 0.3
                color: "red"
            }
            Label {
                anchors.centerIn: parent
                text: "Left-handed"
            }
        }
        MouseArea {
            x : width
            width: parent.width / 2
            height: parent.height
            onClicked: pageStack.push("InlineMenuPage.qml", {rightHanded: true})
            Rectangle {
                anchors.fill: parent
                opacity: 0.3
                color: "green"
            }
            Label {
                anchors.centerIn: parent
                text: "Right-handed"
            }
        }
    }
}
