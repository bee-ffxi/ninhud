# ninhud

a lightweight HUD to display recasts/tool counts for ninjutsu. designed for people who play ninja the right way.

### Usage
Enable this by loading the addon (e.g., in your NIN lua's `OnLoad`), disable it by unloading the addon (e.g., in `OnUnload`). 

### Config
* `yonin_warning` if true, HUD will turn red when yonin buff is not on.
* `tool_name_hint` adds tool name labels beside the toolbag count. 
* `element_instead_of_spell` replaces ninjutsu spell names with effect. E.g., swaps `Hyoton` for `Ice`, and `Hojo` for `Slow`.
* `toolbag_warning_threshold` the number of toolbags in inventory+satchel at which the toolbag count turns yellow.
* `tool_warning_threshold` the number of tools in inventory at which the tool count turns yellow.
* `spell_sequence` the order that spells are listed in the HUD. Include `<linebreak>` to add whitespace.

### TODO
* Add support for ino