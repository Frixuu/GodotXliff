tool
extends Reference

static func codepoint_to_utf8_bytes(unicode: int) -> PoolByteArray:

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
