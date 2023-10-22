extends MarginContainer

# Wires node getters and setters to ViewGD.
var vw = ViewGD.new(self)
func _set(property, value):
	vw.set_v(property, value)
	return true
func _get(property):
	return vw.get_v(property)

## Sent when the stat changes.
signal stat_changed(new_stat: int)

## Declares component properties.
func props() -> Dictionary:
	return {
		"stat_name": "",
		"points": 0,
		"max": 0,
	}

func _ready():
	vw.begin()
	
	vw.bind($HBoxContainer/StatName, "text", "stat_name")
	$HBoxContainer/Spinbox.min = 0
	vw.bind($HBoxContainer/Spinbox, "max", "max")
	
	vw.bind($HBoxContainer/Spinbox, "number", "points", "number_changed")
	$HBoxContainer/Spinbox.connect("number_changed", func(new_num: int): emit_signal("stat_changed", new_num))
	
	$HBoxContainer/Spinbox.text_edit_disabled = true
	
	vw.end()

