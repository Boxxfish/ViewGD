# meta-name: UI Component
# meta-description: Base template for UI components that use ViewGD.

extends _BASE_

# Wires node getters and setters to ViewGD.
var vw := ViewGD.new(self)
func _set(property, value):
	return vw.set_v(property, value)
func _get(property):
	return vw.get_v(property)

## Declares component properties.
func props() -> Dictionary:
	return {
		
	}

func _ready():
	vw.begin()
	vw.end()
