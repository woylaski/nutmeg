import QtQuick 2.4
//import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.0
import Nutmeg 1.0
import FileIO 1.0


Rectangle {
    id: root

    property var settings: null
    onSettingsChanged: console.log("Settings changed:", settings)

    // The actual app menu is built in C++ and triggers these signals from the C++ side
    signal savePdf
    signal selectedPdf(string file)

    signal testFig

    onSavePdf: {
        var fig = tabView.currentFigure()
        console.log("Save PDF")

//        window.savePdfDialog(fig.handle)
    }

    onSelectedPdf: {
        console.log("Pdf Selected:", file)
        tabView.currentFigure().savePdf(file)
    }

    // TODO: Reenable FileDialog when it is possible to set the filename...
//    FileDialog {
//        id: pdfDialog
//        visible: false

//        title: "Please choose a destination"
//        selectExisting: false
//        selectMultiple: false

////        nameFilters: [ "PDF file (*.pdf)"]
////        selectedNameFilter: "PDF file (*.pdf)"

//        onAccepted: {
//            console.log("You chose: " + pdfDialog.fileUrl)
//        }
//        onRejected: {
//            console.log("Canceled")
//        }
////        Component.onCompleted: visible = true
//    }

    FileIO {
        id: testFile
        source: ":/qml/TestFigure.qml"
        onError: console.log("FileIO Error:", msg)
    }

    FileIO {
        id: test3dFile
        source: ":/qml/Test3D.qml"
        onError: console.log("FileIO Error:", msg)
    }

    function testfig() {
        // Connect file dialog signals
//        window.fileSelected.connect(selectedPdf)

        var plotTest = true
        if (plotTest) {
            var qml = testFile.read()

            controller.queueTask("SetFigure", "testFigure", [qml], 1)
//            return

            var xData = [0, 100, 200, 300, 400, 500, 700, 800, 1000, 1200]
            var yData = [0, 1, 2, 3, 2, 1, 3, 5, 2, 10]
            controller.queueTask("SetProperty", "testFigure.ax.blue.x", [xData], 2)
            controller.queueTask("SetProperty", "testFigure.ax.blue.y", [yData], 3)

            controller.queueTask("SetProperty", "testFigure.ax.title", ["Yeah... Plot!!"], 4)
            controller.queueTask("SetProperty", "testFigure.ax.grid.axes", ["XY"], 5)

            controller.queueTask("SetProperty", "testFigure.ax.xAxis.label", ["X Label"], 6)
            controller.queueTask("SetProperty", "testFigure.ax.yAxis.label", ["Coolest Y Label Ever"], 7)

            var xData2 = [0, 50, 200, 300, 450, 500, 700, 1000, 1200]
            var yData2 = [1.000045, 1.000030, 1.000025, 1.000023, 1.000022, 1.0000215,
                                                                    1.0000212, 1.0000211, 1.00002]
            controller.queueTask("SetProperty", "testFigure.ax2.red.x", [xData2], 8)
            controller.queueTask("SetProperty", "testFigure.ax2.red.y", [yData2], 9)

        }
    }

    function test3dfig() {
        var qml = test3dFile.read()
        server.createFigure( {"figureHandle": "test3D", "qml": qml} )

        server.sendData( {"handle": "test3D.ax3d.pc", "data": {
                                "x": [0,7,2,5,6,3,2,6,7,3],
                                "y": [0,1,2,3,2,1,3,5,2,10],
                                "z": [0,5,2,1,7,9,1,2,3,4]
        }} )
    }

    onTestFig: {
        testfig()
    }

//    Test3D {}

    Server {
        id: server
//        portSubscribe: settings ? settings.port : 43686
//        portPublish: settings ? settings.port : 43686
//        figureContainer: figureContainer
//        tabView: tabView
        controller: controller
//        userArea: userArea
    }

    Controller {
        id: controller
        figureContainer: figureContainer
        guiContainer: userArea

        onFigureCreated: tabView.addFigure(figure)
    }

    TabView {
        id: tabView
        anchors.fill: parent
        anchors.rightMargin: userOutline.width

        property var figures: []

        function closeFigure(figure) {
            console.log("Figures before destroy", figures)
            var figureIndex = figure.tabIndex
            var listInd = figures.indexOf(figure)
            figures.splice(listInd, 1)
            figure.destroy()
            removeTab(figureIndex)
            console.log("Figures after destroy", figures)
        }

        function addFigure(figure) {
            console.log("Figures before push", figures)
            figures.push(figure)
            console.log("Figures after push", figures)
            var newTab = addTab(figure.handle, tabDelegate)

            tabView.currentIndex = count - 1
            figure.tabIndex = count - 1
            figure.visible = Qt.binding(function() { return figure.tabIndex == tabView.currentIndex })
            return true
        }

        function currentFigure() {
            return figures[tabView.currentIndex]
        }

        Component {
            id: tabDelegate
            Item {}
        }

        style: TabViewStyle {
            frameOverlap: 1

            tab: Rectangle {
                id: tab
                property int index: styleData.index
                property var figure: null
                // TODO: This is horrible and brittle, but QtQuickControls 1.1 left me no other option...
                onIndexChanged: if (figure) figure.tabIndex = index
                Component.onCompleted: {
                    console.log("Figures:", tabView.figures)
                    figure = tabView.figures[styleData.index]
                    figure.tabIndex = index
                }

                z: -10
                color: styleData.selected ? "white" :"lightsteelblue"
                border.color:  "#777777"
                implicitWidth: Math.max(text.width + closeButton.size + 8, 80)
                implicitHeight: 20
                radius: 2
                Text {
                    id: text
                    x: 2
                    anchors.verticalCenter: parent.verticalCenter
                    text: styleData.title
                    color: styleData.selected ? "black" : "black"
                }

                CloseButton {
                    id: closeButton
                    size: parent.height*0.7
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 0.15*parent.height
                    }
                    onClicked: {
                        tabView.closeFigure(tab.figure)
                    }
                }
            }

            frame: Rectangle {
                color: "white"
                border { color: "#777777"; width: 1 }
            }
        }

    }

//    Item {
//        id: actions
//    }

    FigureContainer {
        id: figureContainer
        tabView: tabView
        anchors.fill: tabView
        anchors.topMargin: 30
    }

    Item {
        id: userOutline
        anchors {
            right: parent.right; top: parent.top; bottom: parent.bottom
        }
        width: -resizeTarget.x

        Rectangle {
            anchors.fill: parent
            border { color: "#AAAAAA"; width: 1 }
        }
        Item {
            id: userArea
            anchors { fill: parent; margins: 5 }
        }
    }

    Item {
        id: resizeTarget
        x: -150
    }

    MouseArea {
        anchors.horizontalCenter: userOutline.left
        height: userOutline.height
        width: 5
        hoverEnabled: true
        cursorShape: Qt.SizeHorCursor
        drag {
            target: resizeTarget
            axis: Drag.XAxis

            maximumX: -50
            minimumX: -parent.width + 50
        }
    }


}