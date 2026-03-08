import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root
    property var pluginApi: null
    property var screen: null // Propiedad requerida por la API de Noctalia
    spacing: Style.marginM

    // Variables de estado
    property string valueSelectedFontFile: pluginApi?.pluginSettings?.selectedFontFile ?? "Anurati-Regular.otf"
    property real valueTextOpacity: pluginApi?.pluginSettings?.textOpacity ?? 1.0
    property bool valueUseThemeColors: pluginApi?.pluginSettings?.useThemeColors ?? true
    
    // Variables de colores
    property color valueCustomPrimaryColor: pluginApi?.pluginSettings?.customPrimaryColor ?? "#FFFFFF"
    property color valueCustomSecondaryColor: pluginApi?.pluginSettings?.customSecondaryColor ?? "#FFFFFF"
    property color valueCustomTextColor: pluginApi?.pluginSettings?.customTextColor ?? "#D0D0D0"

    property var fontListArray: [{"key": "Anurati-Regular.otf", "name": "Cargando fuentes..."}]

    NHeader {
        label: "Ajustes de Modern Clock"
        description: "Configura la apariencia del reloj de escritorio."
    }

    // 1. Escáner automático
    FolderListModel {
        id: fontDirModel
        folder: pluginApi ? "file://" + pluginApi.pluginDir + "/fonts" : ""
        nameFilters: ["*.ttf", "*.otf", "*.TTF", "*.OTF"]
        showDirs: false
        sortField: FolderListModel.Name
        
        // 2. Lógica de conversión: De C++ Model a JS Array
        onStatusChanged: {
            if (status === FolderListModel.Ready) {
                var tempArray = [];
                for (var i = 0; i < count; i++) {
                    var fName = get(i, "fileName");
                    // Estructuramos los datos exactamente como NComboBox los exige
                    tempArray.push({"key": fName, "name": fName});
                }
                root.fontListArray = tempArray;
            }
        }
    }

    // 3. Menú desplegable conectado al arreglo
    NComboBox {
        Layout.fillWidth: true
        label: "Estilo de la fuente principal"
        description: "Agrega archivos .ttf o .otf a la carpeta 'fonts' para verlos aquí."
        model: root.fontListArray
        currentKey: root.valueSelectedFontFile
        onSelected: key => root.valueSelectedFontFile = key
    }

    NValueSlider {
        Layout.fillWidth: true
        label: "Opacidad del widget"
        value: root.valueTextOpacity
        from: 0.1
        to: 1.0
        stepSize: 0.05
        onMoved: value => root.valueTextOpacity = value
    }

    NToggle {
        label: "Usar colores del sistema"
        description: "Aplica los colores dinámicos del fondo de pantalla al texto."
        checked: root.valueUseThemeColors
        onToggled: checked => root.valueUseThemeColors = checked
    }
    
    RowLayout {
        Layout.fillWidth: true
        visible: !root.valueUseThemeColors
        spacing: Style.marginM
        NText { text: "Color de la hora"; Layout.fillWidth: true }
        NColorPicker {
            screen: Screen
            selectedColor: root.valueCustomPrimaryColor
            onColorSelected: color => root.valueCustomPrimaryColor = color
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: !root.valueUseThemeColors
        spacing: Style.marginM
        NText { text: "Color del día"; Layout.fillWidth: true }
        NColorPicker {
            screen: Screen
            selectedColor: root.valueCustomSecondaryColor
            onColorSelected: color => root.valueCustomSecondaryColor = color
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: !root.valueUseThemeColors
        spacing: Style.marginM
        NText { text: "Color de la fecha"; Layout.fillWidth: true }
        NColorPicker {
            screen: Screen
            selectedColor: root.valueCustomTextColor
            onColorSelected: color => root.valueCustomTextColor = color
        }
    }

    function saveSettings() {
        if (!pluginApi) return;
        
        pluginApi.pluginSettings.selectedFontFile = root.valueSelectedFontFile;
        pluginApi.pluginSettings.textOpacity = root.valueTextOpacity;
        pluginApi.pluginSettings.useThemeColors = root.valueUseThemeColors;
        
        pluginApi.pluginSettings.customPrimaryColor = root.valueCustomPrimaryColor.toString();
        pluginApi.pluginSettings.customSecondaryColor = root.valueCustomSecondaryColor.toString();
        pluginApi.pluginSettings.customTextColor = root.valueCustomTextColor.toString();

        pluginApi.saveSettings();
    }
}