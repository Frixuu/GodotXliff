tool
extends EditorPlugin

var importer: XliffImportPlugin = XliffImportPlugin.new()

func _enter_tree():
    add_import_plugin(importer)

func _exit_tree():
    remove_import_plugin(importer)
