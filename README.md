# GodotXliff

XLIFF (monolingual) importer for Godot.  
Currently supports a **reasonable subset** of the XLIFF format.  
_Tested with version 3.3.3 (stable), may work with earlier or later builds too._

## Why

The Godot engine natively supports translations in CSV and PO formats, but that is not enough for some workflows.

## What

[XLIFF](https://en.wikipedia.org/wiki/XLIFF) is an XML-based format for storing localization data. If you have separate XLIFF files for each language in your project, this plugin can help you use them.

## Instructions

- Copy the ```addons``` folder into your project root.
- Enable the plugin in your project's settings tab.
- Import your .xml files as ```XLIFF (Monolingual)```.
- (Recommended) Add your resource files to Project Settings > Localization > Translations, so they can be automatically loaded on game startup.
