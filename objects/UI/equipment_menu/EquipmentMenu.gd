extends Control

var EquipmentIcon = preload("res://objects/UI/equipment_menu/EquipmentIcon.tscn")
var EquipmentItem = preload("res://data/equipment/Equipment.gd")
var section_script = preload("res://objects/UI/equipment_menu/Section.gd")
#var equipment_script = preload("res://data/equipment/Equipment.gd")
# Declare member variables here. Examples:
# var a = 2
onready var center:Vector2 = get_node("EquipmentChartBase").position
onready var icons:Node = get_node("Icons")
onready var card_popup:Node = get_node("CardGUI_Static")
var icon_spread = 76.0
var sections:Array = ["offense","defense","utility"]

var icon_position:Vector2
var icon_info:Dictionary
var mouse_in_icon:bool


# Called when the node enters the scene tree for the first time.
func _ready():
	loadItem("Longsword")

func loadItem(item_name):
	var item:Equipment = load(PlayerVars.EQUIPMENT_LOAD_DIR + item_name + ".tres")
	get_node("Title").text = item.name
	# loop through all sections
	for i in sections.size():
		for t in range(1,5):
			addTier(item,i,t)

func addTier(item:Equipment, section:int = 0, tier:int = 1):
	#Section 0 = Offense, Section 1 = Defense, Section 2 = Utility 
	var cards = item.get(sections[section]+"_tier"+str(tier))
	var radius:int
	var section_name:String
	var section_angle:float = PI/2
	match(section):
		0: 
			section_name = "OffenseTier"+str(tier)
			section_angle = PI/2
		1:
			section_name = "DefenseTier"+str(tier)
			section_angle = (7*PI/6)
		2:
			section_name = "UtilityTier"+str(tier)
			section_angle = (11*PI/6)
	var prev_name:String = section_name.substr(0,11)
	var previous_section:Node = null
	match(tier):
		1: radius = 86
		2: 
			radius = 161
			previous_section = get_node(prev_name+"1")
		3: 
			radius = 236
			previous_section = get_node(prev_name+"2")
		4: 
			radius = 312
			previous_section = get_node(prev_name+"3")
		_: radius = 312
		
	var section_node = get_node(section_name)
	section_node.set_script(section_script)
	if tier == 1:
		section_node.activate()
	if previous_section != null:
		if previous_section.active:
			section_node.unlock()
		else:
			section_node.lock()
	var icon_count = cards.size() - 1
	# add cards within this section
	for i in cards.size():
		var new_card_icon = EquipmentIcon.instance()
		new_card_icon.card_info = CardLoader.loadSingleCardFile(cards[i].card)
		new_card_icon.card_info = CardLoader.combineCardItem(new_card_icon.card_info,item.save())
		new_card_icon.section = section_node
		new_card_icon.prev_section = previous_section
		var spacing = (((icon_count / 2.0) - i) * ((icon_spread/(radius)) + (radius*.0005))) # Arrange in the tier slot with a gradually spread out spacing the higher the tier gets
		var angle = section_angle + spacing
		var angle_vector = (Vector2(radius * cos(angle), - radius * sin(angle)))
		new_card_icon.rect_position = angle_vector + center
		icons.add_child(new_card_icon)
		new_card_icon.setIcon(new_card_icon.card_info.card_icon)
		new_card_icon.updateData(cards[i])

func showCard(position, card_info, proficiency) -> void:
	icon_position = position
	icon_info = card_info
	card_popup.rect_global_position = icon_position
	card_popup.loadNewCardData(icon_info, proficiency)
	card_popup.updateCardInfo()
	mouse_in_icon = true
	get_node("PopupTimer").start()

func hideCard() -> void:
	mouse_in_icon = false
	get_node("PopoutTimer").start()

func _on_PopupTimer_timeout():
	if mouse_in_icon or card_popup.mouse_in:
		card_popup.visible = true

func _on_PopoutTimer_timeout():
	if !mouse_in_icon and !card_popup.mouse_in:
		card_popup.visible = false
