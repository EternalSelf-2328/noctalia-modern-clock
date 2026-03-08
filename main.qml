import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import qs.Commons
import qs.Modules.DesktopWidgets

DraggableDesktopWidget {
    id: root
    property var pluginApi: null

    implicitWidth: 500 * widgetScale
    implicitHeight: 220 * widgetScale
    showBackground: false

    property string dayText: ""
    property string timeText: ""
    property string dateText: ""

    readonly property string activeFontFile: pluginApi?.pluginSettings?.selectedFontFile ?? "Anurati-Regular.otf"
    readonly property real activeOpacity: pluginApi?.pluginSettings?.textOpacity ?? 1.0
    readonly property bool useThemeColors: pluginApi?.pluginSettings?.useThemeColors ?? true
    
    readonly property color customPrimaryColor: pluginApi?.pluginSettings?.customPrimaryColor ?? "#FFFFFF"
    readonly property color customSecondaryColor: pluginApi?.pluginSettings?.customSecondaryColor ?? "#FFFFFF"
    readonly property color customTextColor: pluginApi?.pluginSettings?.customTextColor ?? "#D0D0D0"

    readonly property color colorPrimary: useThemeColors ? Color.mPrimary : customPrimaryColor
    readonly property color colorSecondary: useThemeColors ? Color.mSecondary : customSecondaryColor
    readonly property color colorText: useThemeColors ? Color.mOnSurface : customTextColor

    // 1. Lector de la carpeta de fuentes
    FolderListModel {
        id: fontDirModel
        folder: pluginApi ? "file://" + pluginApi.pluginDir + "/fonts" : ""
        nameFilters: ["*.ttf", "*.otf", "*.TTF", "*.OTF"]
        showDirs: false
    }

    // 2. Pre-caching automático: Instancia un FontLoader por cada archivo encontrado
    Instantiator {
        model: fontDirModel
        delegate: FontLoader {
            source: fileURL
        }
    }

    // 3. El cargador de la fuente actualmente seleccionada
    FontLoader {
        id: currentFont
        source: pluginApi ? "file://" + pluginApi.pluginDir + "/fonts/" + root.activeFontFile : ""
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var date = new Date();
            root.dayText = date.toLocaleDateString(Qt.locale("es_ES"), "dddd").toUpperCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
            root.dateText = date.toLocaleDateString(Qt.locale("es_ES"), "d 'de' MMMM, yyyy");
            root.timeText = date.toLocaleTimeString(Qt.locale(), "hh:mm");
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 5 * widgetScale
        opacity: root.activeOpacity

        Text {
            text: root.dayText
            font.family: currentFont.name
            font.pixelSize: 70 * widgetScale
            font.weight: Font.Bold
            font.letterSpacing: 3 * widgetScale
            color: root.colorText
            anchors.horizontalCenter: parent.horizontalCenter
            style: Text.Outline; styleColor: "#40000000"
        }

        Text {
            text: root.dateText
            font.family: currentFont.name
            font.pixelSize: 20 * widgetScale
            color: root.colorPrimary
            anchors.horizontalCenter: parent.horizontalCenter
            style: Text.Outline; styleColor: "#40000000"
        }

        Text {
            text: root.timeText
            font.family: currentFont.name
            font.pixelSize: 20 * widgetScale
            font.weight: Font.Light
            color: root.colorPrimary
            anchors.horizontalCenter: parent.horizontalCenter
            style: Text.Outline; styleColor: "#40000000"
        }
    }
}