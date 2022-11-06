@tool
extends RefCounted

## Limits the max length of a string.
static func truncate(text: String, max_length: int) -> String:
    if max_length < 2 or text.length() <= max_length:
        return text
    return text.substr(0, max_length - 1) + "…"
