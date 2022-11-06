@tool
extends EditorPlugin

const Common = preload("common.gd")
const ImportLocation = Common.ImportLocation
const XliffImportPlugin = preload("importer.gd")
const IMPORT_LOCATION_SETTING = "addons/xliff/generated_file_location"

var importer: XliffImportPlugin = XliffImportPlugin.new()

func _enter_tree() -> void:
    if not ProjectSettings.has_setting(IMPORT_LOCATION_SETTING):
        ProjectSettings.set_setting(IMPORT_LOCATION_SETTING, ImportLocation.DEFAULT)

    ProjectSettings.add_property_info({
        "name": IMPORT_LOCATION_SETTING,
        "type": TYPE_INT,
        "hint": PROPERTY_HINT_ENUM,
        "hint_string": "Default (typically .import),Next to the original file"
    })
    
    self.add_import_plugin(importer)

func _exit_tree() -> void:
    self.remove_import_plugin(importer)
