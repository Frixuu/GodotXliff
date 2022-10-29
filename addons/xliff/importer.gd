tool
extends EditorImportPlugin

const ParserTools = preload("parser_tools.gd")
const StringTools = preload("string_tools.gd")

## Determines from which part of the file the key will be extracted.
enum KeyExtractor {
    SOURCE_TAG,
    ID,
    RESNAME_OR_ID,
    NONE,
}

func get_importer_name() -> String:
    return "frixuu.xliff"

func get_visible_name() -> String:
    return "XLIFF"

func get_recognized_extensions() -> Array:
    return ["xliff", "xlf", "xml"]

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
            "name": "key_extractor",
            "property_hint": PROPERTY_HINT_ENUM,
            "default_value": 0,
            "hint_string": "Contents of <source>,Segment ID,Segment ResName (or ID as fallback)",
        },
        {
            "name": "override/enabled",
            "default_value": false,
        },
        {
            "name": "override/iso_code",
            "default_value": "",
        },
    ]

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
    var key: String = ""
    var value: String = ""
    var extractor = options.get("key_extractor", KeyExtractor.NONE)

    while parser.read() != ERR_FILE_EOF:

        if parser.get_node_type() == XMLParser.NODE_TEXT:
            continue

        if parser.has_attribute("target-language"):
            translation.locale = parser.get_named_attribute_value("target-language")
        elif parser.has_attribute("trgLang"):
            translation.locale = parser.get_named_attribute_value("trgLang")

        match parser.get_node_name():
            "segment", "trans-unit":
                if parser.is_empty():
                    continue
                match parser.get_node_type():
                    XMLParser.NODE_ELEMENT:
                        key = ""
                        value = ""
                        match extractor:
                            KeyExtractor.RESNAME_OR_ID:
                                key = parser.get_named_attribute_value_safe("resname")
                                if key == "":
                                    key = parser.get_named_attribute_value_safe("id")
                            KeyExtractor.ID:
                                key = parser.get_named_attribute_value_safe("id")
                    XMLParser.NODE_ELEMENT_END:
                        if key != "" && value != "":
                            translation.add_message(key, value)
                        elif key != "":
                            printerr("%s: no value found for key \"%s\""
                                % [source_file, StringTools.truncate(key, 60)])
                        else:
                            printerr("%s: no key matched for value \"%s\""
                                % [source_file, StringTools.truncate(value, 60)])
            "source":
                if extractor != KeyExtractor.SOURCE_TAG:
                    continue
                if parser.get_node_type() == XMLParser.NODE_ELEMENT:
                    key = ParserTools.extract_text_data(parser, source_file)
            "target":
                if parser.get_node_type() == XMLParser.NODE_ELEMENT:
                    value = ParserTools.extract_text_data(parser, source_file)

    # It's possible we may have detected the target language wrongly,
    # override it if it's requested
    if options.get("override/enabled", false):
        translation.locale = options.get("override/iso_code", "")

    var filename = save_path + "." + get_save_extension()
    return ResourceSaver.save(filename, translation)
