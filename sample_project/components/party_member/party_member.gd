extends PanelContainer

# Wires node getters and setters to ViewGD.
var vw = ViewGD.new(self)
func _set(property, value):
	return vw.set_v(property, value)
func _get(property):
	return vw.get_v(property)

## Sent when the edit button is selected.
signal edit_pressed(index: int)

## Sent when the delete button is selected.
signal delete_pressed(index: int)

## Declares component properties.
func props() -> Dictionary:
	return {
		"index": 0,
		"member_data": PartyMemberData.empty()
	}

func _ready():
	vw.begin()
	
	vw.computed("member_name", func(): return self.member_data.name)
	vw.bind($PartyMemberVBox/MarginContainer/VBoxContainer/PartyMemberName, "text", "member_name")
	
	vw.computed("stats_label", func():
		return (
			" S: " + str(self.member_data.stren) +
			" D: " + str(self.member_data.dex) +
			" Co: " + str(self.member_data.con) +
			" W: " + str(self.member_data.wis) +
			" I: " + str(self.member_data.intel) +
			" Ch: " + str(self.member_data.cha)
		)
	)
	vw.bind($PartyMemberVBox/MarginContainer/VBoxContainer/StatsLabel, "text", "stats_label")
	
	$PartyMemberVBox/PartyMemberIcon/ButtonsVBox/DeleteButton.connect("pressed", func(): emit_signal("delete_pressed", self.index))
	$PartyMemberVBox/PartyMemberIcon/ButtonsVBox/EditButton.connect("pressed", func(): emit_signal("edit_pressed", self.index))
	
	vw.end()

