## Stores data for a party member.
class_name PartyMemberData extends Object

var name: String
var stren: int
var dex: int
var con: int
var intel: int
var wis: int
var cha: int

func _init(name: String, stren: int, dex: int, con: int, intel: int, wis: int, cha: int):
	self.name = name
	self.stren = stren
	self.dex = dex
	self.con = con
	self.intel = intel
	self.wis = wis
	self.cha = cha

const consonants = "wrtyplkjgfdszvbm"
const vowels = "aeiou"

## Returns a random character from the string.
static func _rand_char(str: String) -> String:
	return str[randi_range(0, len(str) - 1)]

## Creates a random party member.
static func random() -> PartyMemberData:
	var name := ""
	for i in range(randi_range(2, 3)):
		var syl := _rand_char(consonants) + _rand_char(vowels) + _rand_char(consonants)
		if i == 0:
			syl[0] = syl[0].to_upper()
		name += syl
	return PartyMemberData.new(name, randi_range(0, 4), randi_range(0, 4), randi_range(0, 4), randi_range(0, 4), randi_range(0, 4), randi_range(0, 4))

## Creates an empty party member.
static func empty() -> PartyMemberData:
	return PartyMemberData.new("", 0, 0, 0, 0, 0, 0)
