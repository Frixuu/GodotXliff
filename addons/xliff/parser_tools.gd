@tool
extends RefCounted

const Common = preload("common.gd")
const KeyExtractor = Common.KeyExtractor
const StringTools = preload("string_tools.gd")
const UnicodeTools = preload("unicode_tools.gd")

static func parse_into_translation(
    parser: XMLParser,
    extractor: int,
    translation: Translation,
    hint_file: String = "n/a"
) -> void:

    var key: String = ""
    var value: String = ""

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
                                % [hint_file, StringTools.truncate(key, 60)])
                        else:
                            printerr("%s: no key matched for value \"%s\""
                                % [hint_file, StringTools.truncate(value, 60)])
            "source":
                if (extractor == KeyExtractor.SOURCE_TAG
                    and parser.get_node_type() == XMLParser.NODE_ELEMENT):
                    key = extract_inner_text(parser, hint_file)
            "target":
                if parser.get_node_type() == XMLParser.NODE_ELEMENT:
                    value = extract_inner_text(parser, hint_file)

## Attempts to read XML node contents as text, ignoring markup.
static func extract_inner_text(parser: XMLParser, hint_file: String = "n/a") -> String:

    if parser.get_node_type() != XMLParser.NODE_ELEMENT:
        printerr("passed parser is in an invalid state (not an element start)")
        return ""

    if parser.is_empty():
        printerr("passed parser is in an invalid state (empty node)")
        return ""

    var node_name = parser.get_node_name()
    var data: String = ""
    var depth: int = 0
    var err: int

    while true:
        err = parser.read()

        match err:
            OK:
                pass
            ERR_FILE_EOF:
                printerr("unexpected end of file %s (malformed xml?)" % [hint_file])
                break
            _:
                printerr("unexpected error while reading file %s (code %d)" % [hint_file, err])
                break

        match parser.get_node_type():
            XMLParser.NODE_ELEMENT:
                if parser.get_node_name() == node_name:
                    depth += 1
                else:
                    match parser.get_node_name():
                        "cp":
                            var hex: String = "0x" + parser.get_named_attribute_value("hex")
                            var bytes := UnicodeTools.codepoint_to_utf8_bytes(hex.hex_to_int())
                            data += bytes.get_string_from_utf8()
            XMLParser.NODE_ELEMENT_END:
                if parser.get_node_name() == node_name:
                    depth -= 1
                    if depth < 0:
                        break
            XMLParser.NODE_TEXT:
                data += parser.get_node_data()

    return data
