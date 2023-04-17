@tool
extends EditorImportPlugin

const Common = preload("common.gd")
const KeyExtractor = Common.KeyExtractor
const ImportLocation = Common.ImportLocation
const ParserTools = preload("parser_tools.gd")
const IMPORT_LOCATION_SETTING = "addons/xliff/generated_file_location"

func _get_importer_name() -> String:
    return "frixuu.xliff"

func _get_visible_name() -> String:
    return "XLIFF"

func _get_recognized_extensions() -> PackedStringArray:
    return PackedStringArray(["xliff", "xlf", "xml"])

func _get_save_extension() -> String:
    match ProjectSettings.get_setting(IMPORT_LOCATION_SETTING):
        ImportLocation.DEFAULT:
            return "translation"
        _:
            return ""

func _get_resource_type() -> String:
    return "Translation"

func _get_priority() -> float:
    return 1.0

func _get_import_order() -> int:
    return IMPORT_ORDER_DEFAULT

func _get_preset_count() -> int:
    return 1

func _get_preset_name(_index: int) -> String:
    return "Default"

func _get_import_options(_path: String, _index: int) -> Array[Dictionary]:
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

func _get_option_visibility(_path: String, option_name: StringName, options: Dictionary) -> bool:
    if option_name == "override/iso_code":
        return options.get("override/enabled", false)
    return true

func _import(
    source_file: String,
    save_path: String,
    options: Dictionary,
    platform_variants: Array[String],
    gen_files: Array[String]
 ) -> Error:

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

    match ProjectSettings.get_setting(IMPORT_LOCATION_SETTING):
        ImportLocation.DEFAULT:
            save_path = save_path + "." + _get_save_extension()
            return ResourceSaver.save(translation_object, save_path)
        ImportLocation.ALONGSIDE_ORIGINAL:
            save_path = source_file.get_basename() + ".translation"
            var err := ResourceSaver.save(translation_object, save_path)
            if err != OK:
                printerr("Cannot save resource %s: %d" % [save_path, err])
                return err
            gen_files.push_back(save_path)
            return OK
        _:
            printerr("Invalid import location setting value (%s)" % IMPORT_LOCATION_SETTING)
            return FAILED
