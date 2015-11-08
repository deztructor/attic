// File is generated from carousel-menu.org

import QtQuick 2.0
import Sailfish.Silica 1.0
import "CarouselMenuShaders.js" as MenuShaders
MouseArea {
    id: menu
    anchors.fill: parent

    signal selected(int index)
    onSelected: {
        banner.show(menuModel.get(index).name)
    }
    
    property real itemsCount: menuModel.count
    readonly property real maxItemSize: Theme.itemSizeExtraLarge + Theme.paddingLarge
    property real minRadius: 0
    //property real maxRadius: Math.min(parent.width, parent.height) / 2
    property real maxRadius: maxItemSize * itemsCount / Math.PI
    property real dR: maxRadius - minRadius
    property real radius: minRadius + dR * spread
    property real spread: 0.0
    property real shift: 0.0
    property point centerShift: Qt.point(0.0, 0.0)
    property bool reverse: false
    state: "folded"
    onStateChanged: {
        console.log("state", state)
        switch (state) {
        case "folded":
            spread = 0
            centerShift = Qt.point(0.0, 0.0)
            break;
        default:
            break
        }
    }

    property point center: menuPressedPos
    readonly property real maxAngle: 2 * Math.PI
    property real angleStep: maxAngle / menuModel.count
    property real pointerAngle: 0
    property point menuPressedPos: Qt.point(0, 0)
    property bool dragging: false
    onPressed: {
        if (state === "folded") {
            menuPressedPos = Qt.point(mouse.x, mouse.y)
            state = "dragging"
        }
    }
    function normalize(angle) {
        if (angle >= maxAngle) {
            angle = angle - maxAngle
        } else if (angle < 0) {
            angle = maxAngle + angle
        }
        return angle
    }
    function itemPosition(n) {
        return normalize(n * angleStep + shift)
    }
    function angleToItem(angle, shift) {
        var res = Math.round(normalize(angle - shift) / angleStep)
        return res >= menuModel.count ? 0 : res
    }
    function pressedAngle(angle) {
        var res = normalize(angle)
        // var quadrant = Math.floor(res / (maxAngle / 4))
        // console.log("QUAD", quadrant, "for", res)
        // switch (quadrant) {
        // case 0:
        // case 3:
        //     res += angleStep
        //     break
        // case 1:
        // case 2:
        //     res += angleStep
        //     break
        // default:
        //     console.log("Quadrant???", angle)
        // }
        return res;
    }
    function getPointData(pos) {
        if (reverse) {
            pos.x = -pos.x; pos.y = -pos.y
        }
        var res = {valid: false}
        //var pos = Qt.point(mouse.x, mouse.y)
        var dpos = Qt.point(pos.x - menuPressedPos.x, pos.y - menuPressedPos.y)
        var maxShift = maxItemSize / 4
        var ax = Math.abs(dpos.x), ay = Math.abs(dpos.y)
        res.centerShift = Qt.point(ax > maxShift
                                   ? (dpos.x > 0 ? maxShift
                                      : -maxShift)
                                   : dpos.x
                                   , ay > maxShift
                                   ? (dpos.y > 0
                                      ? maxShift
                                      : -maxShift)
                                   : dpos.y)
        var dsum = ax + ay
        if (dsum > 0) {
            res.valid = true
            var r = Math.sqrt(Math.pow(ax, 2) + Math.pow(ay, 2))
            var scale = r / Theme.itemSizeExtraLarge
            res.spread = Math.min(scale, 1.0)
            res.shift = (scale <= 1.0 ? scale : (scale - Math.floor(scale))) * maxAngle
            var angle = Math.atan2(dpos.y, dpos.x)
            // get it positive
            angle = pressedAngle(angle)
            res.item = angleToItem(angle, res.shift)
            res.angle = angle
        }
        return res
    }
    onPositionChanged: {
        if (state === "dragging" || state === "choosing") {
            var data = getPointData(Qt.point(mouse.x, mouse.y))
            if (!data.valid)
                return;
            //if (spread < 1.0)
            spread = data.spread
            state = spread >= 1.0 ? "choosing" : "dragging"
            shift = data.shift
            pointerAngle = data.angle
            currentItem = data.item
            centerShift = data.centerShift
        }
    }
    Behavior on spread { NumberAnimation {} }
    property int currentItem: -1
    onCurrentItemChanged: console.log("Current", currentItem >= 0
                                      ? menuModel.get(currentItem).name
                                      : "-1")
    onReleased: {
        if (state === "dragging") {
            state = "folded"
        } else if (state === "choosing") {
            var data = getPointData(Qt.point(mouse.x, mouse.y))
            if (data.valid) {
                console.log("ITEMS", data.item, currentItem)
                if (data.item === currentItem)
                    selected(currentItem)
            }
            state = "folded"
        }

    }
    function dump(name, v) {
        //console.log(name, v)
        return v
    }
    Rectangle {
        id: debugSeeMenuArea
        visible: false
        color: "red"
        opacity: 0.2
        anchors.fill: parent
    }
    Item {
        property point center: menu.center
        x: center.x// - width / 2// + menu.centerShift.x
        y: center.y// - height / 2// + menu.centerShift.y
        //height: Theme.itemSizeExtraLarge
        //width: Theme.itemSizeExtraLarge
        Image {
            id: centerImage
            source: "image://theme/icon-m-dot"
            opacity: menu.state === "dragging" ? 1.0 : 0.0
            Behavior on opacity { FadeAnimation {} }
            anchors.centerIn: parent
        }
        Rectangle {
            id: debugViewCenterItemArea
            color: "red"
            opacity: 0.3
            visible: false
            anchors.fill: parent
        }
        Label {
            id: centerLabel
            text: menu.currentItem >= 0 ? menuModel.get(menu.currentItem).name : ""
            opacity: menu.state === "choose" || menu.state === "choosing" ? 1.0 : 0.0
            Behavior on opacity { FadeAnimation {} }
            anchors.centerIn: parent
        }
    }
    Image {
        id: highlightImage
        source: "highlight.png"
        visible: false
    }
    Component {
        id: menuItem
        Item  {
            width: Theme.itemSizeLarge * menu.spread
            height: width
            x: menu.center.x - width / 2
            y: menu.center.y - height / 2
            Image {
                visible: false
                id: menuImage
                source: model.icon
                //position: model.index
            }
            ShaderEffect {
                height: maxH//parent.height
                width: maxW//parent.width
                property variant source: menuImage
                property variant highlightTexture: highlightImage
                property real radius: menu.radius
                property real angle: menu.itemPosition(model.index)
                property real spread: menu.spread
                property real maxW: Theme.itemSizeLarge
                property real maxH: Theme.itemSizeLarge
                property real maxAngle: menu.maxAngle
                property real pointerAngle: menu.pointerAngle
                property bool isSelected: (spread >= 1.0
                                           && menu.currentItem === model.index)
                vertexShader: MenuShaders.carouselItemVertex
                fragmentShader: MenuShaders.carouselItemFragment
            }
        }
    }
    Repeater {
        model: menuModel
        delegate: menuItem
    }
}
