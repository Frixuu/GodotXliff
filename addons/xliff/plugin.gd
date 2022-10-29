tool
extends EditorPlugin

const XliffImportPlugin = preload("importer.gd")
var importer: XliffImportPlugin = XliffImportPlugin.new()

func _enter_tree() -> void:
    self.add_import_plugin(importer)

func _exit_tree() -> void:
    self.remove_import_plugin(importer)
