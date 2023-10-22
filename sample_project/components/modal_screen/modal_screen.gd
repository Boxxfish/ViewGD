extends ColorRect

# Wires node getters and setters to ViewGD.
var vw = ViewGD.new(self)
func _set(property, value):
	return vw.set_v(property, value)
func _get(property):
	return vw.get_v(property)

const MAX_POINTS = 20

const stat_names := ["stren", "dex", "con", "wis", "intel", "cha"]

## Declares component properties.
func props() -> Dictionary:
	var props_dict = {
		"showing": false,
		"member_name": "",
	}
	for stat_name in stat_names:
		props_dict[stat_name] = 0
	return props_dict

## Sent when changes should be discarded.
signal discard_pressed

## Sent when stats have been modified.
signal stats_modified(index: int, data: PartyMemberData)

## Updates the data that the modal modifies.
func update_member_data(index: int, data: PartyMemberData):
	for stat in stat_names:
		self.set(stat, data.get(stat))
	self.member_name = data.name
	self.member_index = index

func _ready():
	vw.begin()
	
	# Logic to show and hide the modal.
	vw.bind(self, "visible", "showing")
	$CenterContainer/Modal/MarginContainer/ModalVBox/MarginContainer/DataVBox/HBoxContainer/DiscardButton.connect("pressed", func(): emit_signal("discard_pressed"))
	
	# Display the number of points we can spend.
	vw.computed("points_left", func():
		var points_left = MAX_POINTS
		for stat_name in stat_names:
			points_left -= self.get(stat_name)
		return points_left
	)
	vw.computed("points_left_text", func(): return "Points Left: " + str(self.points_left))
	vw.bind($CenterContainer/Modal/MarginContainer/ModalVBox/MarginContainer/DataVBox/PointsLeftLabel, "text", "points_left_text")
	
	# Configure all of our stat modifier elements.
	vw.data({
		"member_index": 0,
	})
	for stat_name in stat_names:
		var mod_name = stat_name + "Mod"
		mod_name[0] = mod_name[0].to_upper()
		var stat_mod = $CenterContainer/Modal/MarginContainer/ModalVBox/MarginContainer/DataVBox.get_node(mod_name)
		
		# These don't need to be reactive since they don't change.
		stat_mod.stat_name = stat_name
		stat_mod.text_edit_disabled = true
		
		# Set the current stat points.
		vw.bind(stat_mod, "points", stat_name, "stat_changed")
		
		# Set the maximum value of the stat to the current value + points left.
		vw.computed(stat_name + "_max", func(): return self.get(stat_name) + self.points_left)
		vw.bind(stat_mod, "max", stat_name + "_max")
		
	
	# Handle submission logic.
	$CenterContainer/Modal/MarginContainer/ModalVBox/MarginContainer/DataVBox/HBoxContainer/ApplyButton.connect(
		"pressed",
		func():
			var new_data = PartyMemberData.new(self.member_name, self.stren, self.dex, self.con, self.intel, self.wis, self.cha)
			emit_signal("stats_modified", self.member_index, new_data)
	)
	
	vw.end()

