import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    ListModel {
        id: menuModel
        ListElement { icon: "image://theme/icon-m-folder" }
        ListElement { icon: "image://theme/icon-m-bluetooth" }
        ListElement { icon: "image://theme/icon-m-document" }
        ListElement { icon: "image://theme/icon-m-traffic" }
        ListElement { icon: "image://theme/icon-m-favorite" }
    }
    MouseArea {
        id: menu
        anchors.fill: parent
        property real itemsCount: menuModel.count
        readonly property real maxItemSize: Theme.itemSizeLarge + Theme.paddingLarge
        property real minRadius: 0
        property real maxRadius: maxItemSize * itemsCount / Math.PI / 1.5
        property real dR: maxRadius - minRadius
        property real radius: minRadius + dR * spread
        property real spread: 0.0
        state: spread === 0.0 ? "folded" : (spread === 1.0 ? "expanded" : "progress")

        property point center: Qt.point(width / 2, height / 2)
        readonly property real fullCircleAngle: 2 * Math.PI
        property real itemAngle: fullCircleAngle / menuModel.count
        property real shift: (1 - spread) * fullCircleAngle / 2
        
        property point menuPressedPos: Qt.point(0, 0)
        onPressed: {
            menuPressedPos = Qt.point(mouse.x, mouse.y)
            console.log("P", menuPressedPos)
        }
        onPositionChanged: {
            if (menuPressedPos.x !== 0) {
                var pos = Qt.point(mouse.x, mouse.y)
                var dpos = Qt.point(pos.x - menuPressedPos.x, pos.y - menuPressedPos.y)
                var ax = Math.abs(dpos.x), ay = Math.abs(dpos.y)
                var dsum = ax + ay
                if (dsum > 0) {
                    var r = Math.sqrt(Math.pow(ax, 2) + Math.pow(ay, 2))
                    spread = Math.min(r / Theme.itemSizeLarge, 1.0)
                    var angle = Math.atan2(dpos.y, dpos.x)
                    angle = angle >= 0 ? angle : fullCircleAngle + angle
                    console.log("ITEM", angle, angle / itemAngle)
                }
            }
        }
        Behavior on spread { NumberAnimation {} }
        onReleased: {
            spread = 0
            menuPressedPos = Qt.point(0, 0)
        }
        onClicked: {
            // if (state === "folded")
            //     expandAnimation.start()
            // else if (state === "expanded")
            //     foldAnimation.start()
        }
        //Behavior on radius { SmoothedAnimation { duration: 10000 } }
        // Timer {
        //     interval: 1600
        //     running: true
        //     repeat: false
        //     onTriggered: expandAnimation.start()
        // }
        function dump(name, v) {
            //console.log(name, v)
            return v
        }
        function itemPosition(n) {
            return dump("pos", n * itemAngle + shift)
        }
        // function itemCenter(n) {
        //     var pos = itemPosition(n)
        //     return dump("center",Qt.point(center.x + Math.sin(pos) * radius
        //                                   , center.y + Math.cos(pos) * radius))
        // }
        Rectangle {
            color: "red"
            opacity: 0.2
            anchors.fill: parent
        }
        Image {
            id: centerImage
            source: "image://theme/icon-m-dot"
            property point center: Qt.point(parent.width / 2, parent.height / 2)
            x: center.x - width / 2
            y: center.y - height / 2
            opacity: menu.spread
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
                    height: parent.height
                    width: parent.width
                    property variant source: menuImage
                    property point center: menu.center
                    property real radius: menu.radius
                    property real angle: menu.itemPosition(model.index)
                    property real spread: menu.spread
                    property real maxW: Theme.itemSizeLarge
                    property real maxH: Theme.itemSizeLarge
                    vertexShader: "
                        uniform highp mat4 qt_Matrix;
                        attribute highp vec4 qt_Vertex;
                        attribute highp vec2 qt_MultiTexCoord0;
                        varying highp vec2 qt_TexCoord0;
                        uniform mediump vec2 center;
                        uniform mediump float radius; 
                        uniform mediump float angle; 
                        uniform mediump float spread; 
                        uniform mediump float maxW; 
                        uniform mediump float maxH; 
                        void main() {
                            qt_TexCoord0 = qt_MultiTexCoord0;
                            highp vec4 shift = vec4(1.0, 1.0, 0.0, 0.0);
                            highp mat4 scale = qt_Matrix * mat4(spread, 0.0, 0.0, 0.0, 0.0, spread, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0);
                            shift.x = sin(angle) * radius;
                            shift.y = cos(angle) * radius;
                            gl_Position = scale * (qt_Vertex + shift);
                        }"
                    fragmentShader: "
                        varying highp vec2 qt_TexCoord0;
                        uniform sampler2D source;
                        uniform mediump float spread;
                        uniform lowp float qt_Opacity;
                        void main() {
                            float opac = qt_Opacity * spread;
                            gl_FragColor = texture2D(source, qt_TexCoord0) * opac;
                        }"
                 }
            }
        }
        Repeater {
            model: menuModel
            delegate: menuItem
        }
    }
}
