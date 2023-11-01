extends Resource
class_name Equipment

export(String) var name = ""
export(Array, int, "None", "Unarmed", "Sword", "Dagger", "Bludgeon", "Axe", "Polearm",
 "Bow", "Staff", "Tome", "Magic", "Shield") var type
export(Array, String, "Primary_Hand", "Secondary_Hand", "Accessory", "Head", "Body", "Leg") var slot
export(bool) var is_two_handed = false
export(int, 0, 5) var rarity
export(Texture) var texture
export(int) var base_damage
export(int) var base_ap
export(String) var description
export(Array, Resource) var inscriptions
export(Array, Resource) var offense_tier1
export(Array, Resource) var offense_tier2
export(Array, Resource) var offense_tier3
export(Array, Resource) var offense_tier4
export(Array, Resource) var offense_tier5
export(Array, Resource) var defense_tier1
export(Array, Resource) var defense_tier2
export(Array, Resource) var defense_tier3
export(Array, Resource) var defense_tier4
export(Array, Resource) var defense_tier5
export(Array, Resource) var utility_tier1
export(Array, Resource) var utility_tier2
export(Array, Resource) var utility_tier3
export(Array, Resource) var utility_tier4
export(Array, Resource) var utility_tier5


#in unit
#var skills:Array = [["Sword", 30]]                         # [skill name, skill points]

#in item
#var item_info:Array = [["offense_tier1",0,2]]              # [section,slot,proficency]
func save() -> Dictionary:
	var save_dict = {
		"name": name,
		"type": type,
		"slot": slot,
		"is_two_handed": is_two_handed,
		"rarity": rarity,
		"texture": texture,
		"base_damage": base_damage,
		"base_ap": base_ap,
		"inscriptions": inscriptions,
		"offense_tier1": offense_tier1,
		"offense_tier2": offense_tier2,
		"offense_tier3": offense_tier3,
		"offense_tier4": offense_tier4,
		"offense_tier5": offense_tier5,
		"defense_tier1": defense_tier1,
		"defense_tier2": defense_tier2,
		"defense_tier3": defense_tier3,
		"defense_tier4": defense_tier4,
		"defense_tier5": defense_tier5,
		"utility_tier1": utility_tier1,
		"utility_tier2": utility_tier2,
		"utility_tier3": utility_tier3,
		"utility_tier4": utility_tier4,
		"utility_tier5": utility_tier5
	}
	return save_dict

func loadData(data) -> void:
	name = data.name
	type = data.type
	slot = data.slot
	is_two_handed = data.is_two_handed
	rarity = data.rarity
	texture = data.texture
	base_damage = data.base_damage
	base_ap = data.base_ap
	inscriptions = data.inscriptions
	offense_tier1 = data.offense_tier1
	offense_tier2 = data.offense_tier2
	offense_tier3 = data.offense_tier3
	offense_tier4 = data.offense_tier4
	offense_tier5 = data.offense_tier5
	
	defense_tier1 = data.defense_tier1
	defense_tier2 = data.defense_tier2
	defense_tier3 = data.defense_tier3
	defense_tier4 = data.defense_tier4
	defense_tier5 = data.defense_tier5
	
	utility_tier1 = data.utility_tier1
	utility_tier2 = data.utility_tier2
	utility_tier3 = data.utility_tier3
	utility_tier4 = data.utility_tier4
	utility_tier5 = data.utility_tier5
