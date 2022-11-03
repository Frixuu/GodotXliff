tool
extends EditorImportPlugin

const Common = preload("common.gd")
const KeyExtractor = Common.KeyExtractor
const ImportLocation = Common.ImportLocation
const ParserTools = preload("parser_tools.gd")
const IMPORT_LOCATION_SETTING = "addons/xliff/generated_file_location"

func get_importer_name() -> String:
    return "frixuu.xliff"

func get_visible_name() -> String:
    return "XLIFF"

func get_recognized_extensions() -> Array:
    return ["xliff", "xlf", "xml"]

func get_save_extension() -> String:
    match ProjectSettings.get_setting(IMPORT_LOCATION_SETTING):
        ImportLocation.DEFAULT:
            return "translation"
        _:
            return ""

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

    match ProjectSettings.get_setting(IMPORT_LOCATION_SETTING):
        ImportLocation.DEFAULT:
            save_path = save_path + "." + get_save_extension()
            return ResourceSaver.save(save_path, translation_object)
        ImportLocation.ALONGSIDE_ORIGINAL:
            save_path = source_file.get_basename() + ".translation"
            var err := ResourceSaver.save(save_path, translation_object)
            if err != OK:
                printerr("Cannot save resource %s: %d" % [save_path, err])
                return err
            gen_files.push_back(save_path)
            return OK
        _:
            printerr("Invalid import location setting value (%s)" % IMPORT_LOCATION_SETTING)
            return FAILED
