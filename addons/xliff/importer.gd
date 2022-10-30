tool
extends EditorImportPlugin

const Common = preload("common.gd")
const KeyExtractor = Common.KeyExtractor
const ParserTools = preload("parser_tools.gd")

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

    var translation_object: Translation = Translation.new()

    var extractor = options.get("key_extractor", KeyExtractor.NONE)
    ParserTools.parse_into_translation(parser, extractor, translation_object, source_file)

    # It's possible we may have detected the target language incorrectly,
    # override it if it's requested
    if options.get("override/enabled", false):
        translation_object.locale = options.get("override/iso_code", "")

    save_path = save_path + "." + get_save_extension()
    return ResourceSaver.save(save_path, translation_object)
