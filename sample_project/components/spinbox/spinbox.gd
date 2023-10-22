extends Control

# Wires node getters and setters to ViewGD.
var vw = ViewGD.new(self)
func _set(property, value):
	return vw.set_v(property, value)
func _get(property):
	return vw.get_v(property)

## Emitted when the number changes.
signal number_changed(new_value: int)

## Declares component properties.
func props() -> Dictionary:
	return {
		"number": 0,
		"min": 0,
		"max": 10,
		"text_edit_disabled": false,
	}

func _ready():
	vw.begin()
	
	vw.watch(["number"], func(): emit_signal("number_changed", self.number))
	vw.bind($Number, "text", "number", "text_changed")
	vw.computed("not_text_edit_disabled", func(): return not self.text_edit_disabled)
	vw.bind($Number, "editable", "not_text_edit_disabled")

	vw.computed("minus_disabled", func(): return self.number <= self.min)
	vw.bind($Minus, "disabled", "minus_disabled")
	$Minus.connect("pressed", func(): self.number -= 1)
	
	vw.computed("plus_disabled", func(): return self.number >= self.max)
	vw.bind($Plus, "disabled", "plus_disabled")
	$Plus.connect("pressed", func(): self.number += 1)
	
	vw.end()

