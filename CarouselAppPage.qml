// File is generated from carousel-menu.org

import QtQuick 2.0
import Sailfish.Silica 1.0
import "CarouselMenuShaders.js" as MenuShaders

Page {
    ListModel {
        id: menuModel
        ListElement { icon: "image://theme/icon-m-folder"; name: "Folder" }
        ListElement { icon: "image://theme/icon-m-bluetooth"; name: "Bluetooth" }
        ListElement { icon: "image://theme/icon-m-document"; name: "Document" }
        ListElement { icon: "image://theme/icon-m-traffic"; name: "Traffic" }
        ListElement { icon: "image://theme/icon-m-favorite"; name: "Favorite" }
        ListElement { icon: "image://theme/icon-m-display"; name: "Display" }
        ListElement { icon: "image://theme/icon-m-storage"; name: "Storage" }
        ListElement { icon: "image://theme/icon-m-vibration"; name: "Vibration" }
        ListElement { icon: "image://theme/icon-m-timer"; name: "Timer" }
    }
    Label {
        id: hintLabel
        x: menu.center.x < parent.width / 2
            ? parent.width - width
            : 0
        y: menu.center.y < parent.height / 2
            ? parent.height - height
            : 0
        width: parent.width / 4 * 3
        height: Theme.itemSizeExtraLarge * 2
        wrapMode: Text.WordWrap
        text: {
            var res = ""
            switch (menu.state) {
            case "folded":
                res = "Press anywhere, hold and start to move away."
                break
            case "dragging":
                res = "To start selection, hold and move away from the initial press position.<br/> Or just release to fold menu back."
                break
            case "choosing":
                res = "To choose item: hold and move away or move around, then release to trigger.<br/>
    To fold menu back: Move back to the place near initial press position until dot is shown and release."
                break
            case "choose":
                res = "Click on the chosen item to confirm selection or click in another place to cancel."
                break
            default:
                res = "There is no help for the current state"
            }
            return res
        }
    }
    SimpleBanner {
        id: banner
    }
    CarouselMenu {
        id: menu
        // use model property
    }
}
