extends Control

# Wires node getters and setters to ViewGD.
var vw = ViewGD.new(self)
func _set(property, value):
	return vw.set_v(property, value)
func _get(property):
	return vw.get_v(property)

## Declares component properties.
func props() -> Dictionary:
	return {
		"party_members": [
			PartyMemberData.new("Garglothar the Destroyer", 8, 2, 3, 1, 1, 1),
		],
	}

func _ready():
	vw.begin()
	
	# Create a party member component for each member.
	vw.data({
		"editing_member": -1, # -1 if not editing anyone, otherwise index of the member
	})
	vw.foreach(
		"party_members",
		$MainVBox/PartyMembersScroll/PanelContainer/MarginContainer/PartyMembersFlow,
		"components/party_member/party_member.tscn",
		func(c, d: PartyMemberData, i):
			c.member_data = d
			c.index = i
			c.connect("edit_pressed", func(index: int): 
				$ModalContainer/ModalScreen.update_member_data(index, self.party_members[index])
				self.editing_member = index
			)
			c.connect("delete_pressed", func(index: int): self.party_members = vw.pop_at(self.party_members, index))
	)
	
	# Create a random party member when we click the add button.
	$MainVBox/TopPanel/MarginContainer/TopHBox/AddButton.connect(
		"pressed",
		func(): self.party_members = vw.append(self.party_members, PartyMemberData.random())
	)
	
	# Don't allow moving to the next screen unless we have at least 4 members.
	vw.computed("not_enough_members", func(): return len(self.party_members) < 4)
	vw.computed("explore_tooltip", func(): return "Your party needs at least 4 members." if self.not_enough_members else "")
	var explore_button = $MainVBox/TopPanel/MarginContainer/TopHBox/ExploreButton
	vw.bind(explore_button, "disabled", "not_enough_members")
	vw.bind(explore_button, "tooltip_text", "explore_tooltip")
	
	# Modal logic
	vw.computed("is_editing", func(): return self.editing_member != -1)
	var modal_screen = $ModalContainer/ModalScreen
	vw.bind(modal_screen, "showing", "is_editing")
	modal_screen.connect("discard_pressed", func(): self.editing_member = -1)
	modal_screen.connect("stats_modified", func(i: int, new_data: PartyMemberData):
		self.party_members = vw.set_at(self.party_members, i, new_data)
		self.editing_member = -1
	)
	
	vw.end()

