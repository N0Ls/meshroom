import QtQuick 2.11
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import MaterialIcons 2.2
import Controls 1.0
import Utils 1.0

FloatingPane {
    id: root
    anchors.margins: 0
    padding: 5
    radius: 0

    property int opacityDefaultValue: 100

    property real slidersPowerValue: 4
    property int opacityValue: Math.pow(opacityCtrl.value, 1)

    property variant colorRGBA: null
    property bool displayGrid: displayGridButton.checked
    property bool displayPoints: displayCtrlPointsButton.checked

    property var colors: [Colors.lightgrey, Colors.grey, Colors.red, Colors.green, Colors.blue, Colors.yellow]
    readonly property int colorIndex: (colorOffset) % root.colors.length
    property int colorOffset: 0
    property color color: root.colors[gridColorPicker.currentIndex]

    background: Rectangle { color: root.palette.window }

    DoubleValidator {
        id: doubleValidator
        locale: 'C' // use '.' decimal separator disregarding of the system locale
    }

    RowLayout {
        id: toolLayout
        // anchors.verticalCenter: parent
        anchors.fill: parent

        MaterialToolButton {
            id: displayCtrlPointsButton
            ToolTip.text: "Display Control Points"
            text: MaterialIcons.control_point
            font.pointSize: 13
            padding: 5
            Layout.minimumWidth: 0
            checkable: true
            checked: true
        }
        MaterialToolButton {
            id: displayGridButton
            ToolTip.text: "Display Grid"
            text: MaterialIcons.grid_on
            font.pointSize: 13
            padding: 5
            Layout.minimumWidth: 0
            checkable: true
            checked: false
        }
        ColorChart {
            id : gridColorPicker
            padding : 10
            colors: root.colors
            currentIndex: root.colorIndex
            onColorPicked: root.colorOffset = colorIndex
        }

        // Grid opacity slider
        RowLayout {
            spacing: 5

            ToolButton {
                text: "Grid Opacity"

                ToolTip.visible: ToolTip.text && hovered
                ToolTip.delay: 100
                ToolTip.text: "Reset Opacity"

                onClicked: {
                    opacityCtrl.value = opacityDefaultValue;
                }
            }
            TextField {
                id: opacityLabel

                ToolTip.visible: ToolTip.text && hovered
                ToolTip.delay: 100
                ToolTip.text: "Grid opacity"

                text: opacityValue.toFixed(1)
                Layout.preferredWidth: textMetrics_opacityValue.width
                selectByMouse: true
                validator: doubleValidator
                onAccepted: {
                    opacityCtrl.value = Number(opacityLabel.text)
                }
            }
            Slider {
                id: opacityCtrl
                Layout.fillWidth: false
                from: 0
                to: 100
                value: opacityDefaultValue
                stepSize: 1
            }
        }
        //Fill rectangle to have a better UI
        Rectangle {
        color: root.palette.window
        Layout.fillWidth: true
        }

    }

    TextMetrics {
        id: textMetrics_opacityValue
        font: opacityLabel.font
        text: "100.000"
    }
}
