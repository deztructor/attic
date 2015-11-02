import QtQuick 2.0
import Sailfish.Silica 1.0

MenuItem {
    id: self
    width: parent.width
    height: baseHeight
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    highlighted: (parent.dragY > y && parent.dragY < y + height)
    onHighlightedChanged: {
        if (highlighted && parent.state === "opening") {
            console.log("I am highlighted", text, parent.dragY, parent.state)
            listItem.currentMenuItem = self
        }
    }
    Rectangle {
        x: 0
        opacity: parent.highlighted ? 1.0 : 0.0
        height: Theme.itemSizeSmall
        width: parent.width
        anchors.centerIn: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightColor, 0.1) }
            GradientStop { position: 0.5; color: Theme.rgba(Theme.highlightColor, 0.3) }
            GradientStop { position: 1.0; color: Theme.rgba(Theme.highlightColor, 0.1) }
        }
    }
}
