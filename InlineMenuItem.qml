import QtQuick 2.0
import Sailfish.Silica 1.0

Label {
    id: self
    width: parent.width
    height: baseHeight
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    property bool highlighted: (parent.dragY > y && parent.dragY < y + height)
    signal clicked
    onHighlightedChanged: {
        if (highlighted && parent.state === "opening") {
            listItem.currentMenuItem = self
        }
    }
    // Rectangle {
    //     x: 0
    //     opacity: parent.highlighted ? 1.0 : 0.0
    //     height: Theme.itemSizeSmall
    //     width: parent.width
    //     anchors.centerIn: parent
    //     gradient: Gradient {
    //         GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightColor, 0.1) }
    //         GradientStop { position: 0.5; color: Theme.rgba(Theme.highlightColor, 0.3) }
    //         GradientStop { position: 1.0; color: Theme.rgba(Theme.highlightColor, 0.1) }
    //     }
    // }
}
