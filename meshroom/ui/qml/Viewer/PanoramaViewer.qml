import QtQuick 2.11
import Utils 1.0

import AliceVision 1.0 as AliceVision

/**
 * FloatImage displays an Image with gamma / offset / channel controls
 * Requires QtAliceVision plugin.
 */

AliceVision.PanoramaViewer {
    id: root

    width: 3000
    height: 1000
    visible: (status === Image.Ready)

    // paintedWidth / paintedHeight / status for compatibility with standard Image
    property int paintedWidth: textureSize.width
    property int paintedHeight: textureSize.height
    property var status: {
        if(root.loading)
            return Image.Loading;
        else if((root.source === "") ||
                (root.sourceSize.height <= 0) ||
                (root.sourceSize.width <= 0))
            return Image.Null;
        root.defaultControlPoints();
        updateSfmPath();
        return Image.Ready;
    }

    property int downscale: 2

    clearBeforeLoad: true

    channelMode : AliceVision.PanoramaViewer.EChannelMode.RGBA

    property alias containsMouse: mouseAreaPano.containsMouse
    property alias mouseX: mouseAreaPano.mouseX
    property alias mouseY: mouseAreaPano.mouseY

    property var mouseXClicked : 0
    property var mouseYClicked : 0
    property var mouseXReleased : 0
    property var mouseYReleased : 0
    property var deltaMouseX: mouseXReleased-mouseXClicked
    property var deltaMouseY: mouseYReleased-mouseYClicked

    property bool isRotating: false
    property var lastX : 0
    property var lastY: 0

    Item {
        id: containerPanorama
        Rectangle {
            width: 3000
            height: 1000
            //color: mouseAreaPano.containsMouse? "red" : "green"
            color: "grey"
            MouseArea {
                id: mouseAreaPano
                anchors.fill: parent
                hoverEnabled: true

                onPositionChanged: {
                    // Send Mouse Coordinates to Float Images Viewers
                    for (var i = 0; i < repeater.model; i++) {
                        var highlight = repeater.itemAt(i).item.getMouseCoordinates(mouse.x, mouse.y);
                        repeater.itemAt(i).z = highlight ? 2 : 0
                    }

                    // Rotate Panorama
                    if (isRotating) {
                        var xoffset = mouse.x - lastX;
                        var yoffset = mouse.y - lastY;
                        lastX = mouse.x;
                        lastY = mouse.y;
                        for (var i = 0; i < repeater.model; i++) {
                            repeater.itemAt(i).item.rotatePanorama(xoffset * 0.01, yoffset)
                        }
                    }
                }

                onPressed:{
                    isRotating = true;
                    mouseXClicked = lastX
                    mouseYClicked = lastY
                }

                onReleased: {
                    isRotating = false;
                }
            }
        }
    }




    property string sfmPath: ""

    function updateSfmPath() {
        var activeNode = _reconstruction.activeNodes.get('sfm').node;

        if(!activeNode)
        {
            root.sfmPath = "";
        }
        else
        {
            root.sfmPath = activeNode.attribute("outputViewsAndPoses").value;
        }
        root.setSfmPath(sfmPath);
    }

    property var pathList : []
    property var idList : []

    Item {
        id: panoImages
        width: root.width
        height: root.height

//        function setSource() {
//            if (repeater.model === 0)
//                return

////            var width = repeater.itemAt(0).width;
////            var height = repeater.itemAt(0).height;

//            for (let i = 0; i < repeater.model; i++) {
//                console.warn(repeater.itemAt(i))
////                repeater.itemAt(i).x = root.getVertex(i).x - (width / 2);
////                repeater.itemAt(i).y = root.getVertex(i).y - (height / 2);
//            }
//        }

        Component {
            id: imgPano
            Loader {
                id: floatOneLoader
                active: root.status
                visible: (floatOneLoader.status === Loader.Ready)
                z:0
                //anchors.centerIn: parent
                property string cSource: Filepath.stringToUrl(root.pathList[index].toString())
                property int cId: root.idList[index]
                onActiveChanged: {
                    if(active) {
                        setSource("FloatImage.qml", {
                            'isPanoViewer' : true,
                            'source':  Qt.binding(function() { return cSource; }),
                            'index' : index,
                            'idView': Qt.binding(function() { return cId; }),
                        })
                        console.warn(cSource)
                    } else {
                        // Force the unload (instead of using Component.onCompleted to load it once and for all) is necessary since Qt 5.14
                        setSource("", {})
                    }
                }
            }
        }
        Repeater {
            id: repeater
            model: 0
            delegate: imgPano

        }
        Connections {
            target: root
            onImagesDataChanged: {
                //We receive the map<ImgPath, idView> from C++
                console.warn("IMAGES DATA CHANGED ! " + imagesData)

                //Resetting arrays to avoid problem with push
                pathList = []
                idList = []

                //Iterating through the map
                for (var path in imagesData) {
                    console.warn("Object item:", path, "=", imagesData[path])
                    root.pathList.push(path)
                    root.idList.push(imagesData[path])
                }
                console.warn(root.pathList.length)

                //Changing the repeater model (number of elements)
                panoImages.updateRepeater()

            }
        }
        function updateRepeater() {
            if(repeater.model !== root.pathList.length){
                repeater.model = 0;
            }
            //console.warn(imagesData.length)
            repeater.model = root.pathList.length;
        }
    }



}
