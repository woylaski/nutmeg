import Nutmeg 1.0
import QtQuick 2.0

GUIItem {
    id: controlItem
    property string handle: "guiItem"
    property var value: 0
    property var gui: null

    signal setValue(real newvalue)

    Component.onCompleted: {
        findGui()
        registerProperties({"value":"value"})
    }

    function findGui() {
        if (gui) return // Already found it...

        var names = []
        var ancestor = parent
        while (ancestor) {
            names.push(ancestor.objectName)
            if (ancestor.objectName == "GUI") {
                gui = ancestor
                gui.registerParameter(controlItem)
                return
            }
            ancestor = ancestor.parent
        }

        if (!gui) {
            print("WARNING: GUI parent not found for ControlItem!")
            print("Names:", names)
        }
    }

    onParentChanged: findGui()
}
