tool
extends Reference

## Determines from which part of the file the key will be extracted.
enum KeyExtractor {
    ## The key will come from the text between <source></source>
    ## (it will be the string in the source language).
    SOURCE_TAG,
    ## - If using XLIFF 1.x, will use ID of a <trans-unit> (required by spec).
    ## Be aware it is guaranteed to be unique within the same file only.
    ## - If using XLIFF 2.x, it will only try to read ID of a <segment> (optional),
    ## as <unit>s can have multiple segments, which is incompatible
    ## with Godot's translation model.
    ID,
    ## If using XLIFF 1.x, will use resname of a <trans-unit>.
    ## If the parses cannot find it, falls back to reading the unit's ID.
    RESNAME_OR_ID,
    NONE,
}

enum ImportLocation {
    ## The file will be saved to Godot's chosen location, typically res://.import
    DEFAULT,
    ## The generated file will be generated at the original's location.
    ALONGSIDE_ORIGINAL,
}
