tool
extends Reference

class_name XliffParserHelper

func extract_text_data(parser: XMLParser, hint_file: String = "n/a") -> String:

    if parser.get_node_type() != XMLParser.NODE_ELEMENT:
        printerr("passed parser is in an invalid state (not a element start)")
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
                            data += unicode_to_utf8_bytes(hex_i).get_string_from_utf8()
            XMLParser.NODE_ELEMENT_END:
                if parser.get_node_name() == node_name:
                    depth -= 1
                    if depth < 0:
                        break
            XMLParser.NODE_TEXT:
                data += parser.get_node_data()

    return data

func unicode_to_utf8_bytes(unicode: int) -> PoolByteArray:
    var before: int = unicode
    var arr = PoolByteArray([])

    if unicode < 0:
        printerr("unicode symbol must be a non-negative integer")
        return arr

    if unicode <= 127:
        arr.push_back(unicode)
        return arr

    var length: int
    if unicode <= 2047:
        length = 2
    elif unicode <= 65535:
        length = 3
    elif unicode <= 1114111:
        length = 4
    else:
        printerr(unicode, " cannot be represented in UTF-8")
        return arr

    var part: int
    for i in length - 1:
        part = unicode & 63
        unicode = unicode >> 6
        arr.push_back(part + 128)

    match length:
        2:
            part = (unicode & 31) + 192
        3:
            part = (unicode & 15) + 224
        _:
            part = (unicode & 7) + 240

    arr.push_back(part)
    arr.invert()
    return arr
