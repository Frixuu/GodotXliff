tool
extends Reference

const UnicodeTools = preload("unicode_tools.gd")

static func extract_text_data(parser: XMLParser, hint_file: String = "n/a") -> String:

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
                            var hex_i: int = hex.hex_to_int()
                            var bytes := UnicodeTools.codepoint_to_utf8_bytes(hex_i)
                            data += bytes.get_string_from_utf8()
            XMLParser.NODE_ELEMENT_END:
                if parser.get_node_name() == node_name:
                    depth -= 1
                    if depth < 0:
                        break
            XMLParser.NODE_TEXT:
                data += parser.get_node_data()

    return data
