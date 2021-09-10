tool
extends EditorImportPlugin

class_name XliffImportPlugin

func get_importer_name() -> String:
    return "frixuu.xliff"

func get_visible_name() -> String:
    return "XLiff (Monolingual)"

func get_recognized_extensions() -> Array:
    return ["xml"]

func get_save_extension() -> String:
    return "translation"

func get_resource_type() -> String:
    return "Translation"

func get_preset_count() -> int:
    return 1

func get_preset_name(_i: int) -> String:
    return "Default"

func get_import_options(_i: int) -> Array:
    return [
        {
            "name": "override/enabled",
            "default_value": false,
        },
        {
            "name": "override/iso_code",
            "default_value": "",
        }]

func get_option_visibility(option: String, options: Dictionary) -> bool:
    if option == "override/iso_code":
        return options.get("override/enabled", false)
    return true

func import(
    source_file: String,
    save_path: String,
    options: Dictionary,
    platform_variants: Array,
    gen_files: Array
 ) -> int:

    var parser: XMLParser = XMLParser.new()

    if parser.open(source_file) != OK:
        return FAILED

    var translation: Translation = Translation.new()

    var _err: int
    var _key: String = ""
    var _value: String = ""

    while parser.read() != ERR_FILE_EOF:

        if parser.get_node_type() == XMLParser.NODE_TEXT:
            continue

        if parser.has_attribute("trgLang"):
            translation.locale = parser.get_named_attribute_value("trgLang")

        if parser.has_attribute("target-language"):
            translation.locale = parser.get_named_attribute_value("target-language")

        match parser.get_node_name():
            "segment", "trans-unit":
                if parser.is_empty():
                    continue
                match parser.get_node_type():
                    XMLParser.NODE_ELEMENT:
                        _key = ""
                        _value = ""
                    XMLParser.NODE_ELEMENT_END:
                        if _key != "" && _value != "":
                            translation.add_message(_key, _value)
            "source":
                if parser.get_node_type() != XMLParser.NODE_ELEMENT_END:
                    _err = parser.read()
                    _key = parser.get_node_data()
            "target":
                if parser.get_node_type() != XMLParser.NODE_ELEMENT_END:
                    _err = parser.read()
                    _value = parser.get_node_data()

    if options.get("override/enabled", false):
        translation.locale = options.get("override/iso_code", "")

    var filename = save_path + "." + get_save_extension()
    return ResourceSaver.save(filename, translation)
