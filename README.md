# GodotXliff

XLIFF translation importer for Godot 3.x.

While the main motivation was handling files exported by Weblate,
it currently supports a _reasonable subset_ of both XLIFF 1.2 and 2.0.

## What

[XLIFF](https://en.wikipedia.org/wiki/XLIFF) is an XML-based format for storing localization data. If you have separate XLIFF files for each language in your project, this plugin can help you use them.

## Why

The Godot engine natively supports translations in CSV and PO formats,
but those may not be the best choice for some workflows.

## Instructions

- Copy the `addons` folder into your project root.
- Enable the plugin in your `Project Settings > Plugins` tab.
- Import your files as `XLIFF`.
- (Recommended) Add your resource files to `Project Settings > Localization > Translations`, so they can be automatically loaded on game startup.

## License

GodotXliff is primarily distributed under the terms of both the MIT license and the Apache License (Version 2.0).

See [LICENSE-APACHE](addons/xliff/LICENSE-APACHE.txt) and [LICENSE-MIT](addons/xliff/LICENSE-MIT.txt) for details.
