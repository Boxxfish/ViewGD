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
	
	# Emit signal whenever `number` changes.
	vw.watch(["number"], func(): emit_signal("number_changed", self.number))
	
	# Central textbox; its text field has a two way binding with `number`.
	vw.bind($Number, "text", "number", "text_changed")
	vw.bind($Number, "editable", func(): return not self.text_edit_disabled)

	# Minus button; disabled when number is less than `min`.
	vw.bind($Minus, "disabled", func(): return self.number <= self.min)
	$Minus.connect("pressed", func(): self.number -= 1)
	
	# Plus button; disabled when number is more than `max`.
	vw.bind($Plus, "disabled", func(): return self.number >= self.max)
	$Plus.connect("pressed", func(): self.number += 1)
	
	vw.end()

