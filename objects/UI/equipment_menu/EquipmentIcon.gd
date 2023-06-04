extends Control

# Declare member variables here. Examples:
# var a = 2
var card_info:Dictionary
var section:Node
var prev_section:Node = null
var amount:int
var icon_spread:int = 12
var radius:float = 27
var proficiency:int


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func updateData(data):
	amount = data.amount
	proficiency = data.proficiency
	match proficiency:
		0:
			$Position2D.visible = false
			$Position2D/IconStar.visible = false
			$Position2D/IconStar2.visible = false
			$Position2D/IconStar3.visible = false
		1:
			section.activate()
			$Position2D.visible = true
			$Position2D/IconStar.visible = true
			$Position2D/IconStar2.visible = false
			$Position2D/IconStar3.visible = false
			$Position2D.position.x = 18
		2:
			section.activate()
			$Position2D.visible = true
			$Position2D/IconStar.visible = true
			$Position2D/IconStar2.visible = true
			$Position2D/IconStar3.visible = false
			$Position2D.position.x = 9
		3:
			section.activate()
			$Position2D.visible = true
			$Position2D/IconStar.visible = true
			$Position2D/IconStar2.visible = true
			$Position2D/IconStar3.visible = true
			$Position2D.position.x = 0
	
	var icon_count = amount - 1
	# add cards within this section
	for i in range(amount):
		var amount_sprite = Sprite.new()
		var spacing = (((icon_count / 2.0) - i) * ((icon_spread/(radius)) + (radius*.0005))) # Arrange in the tier slot with a gradually spread out spacing the higher the tier gets
		var angle = ((3*PI)/2) + spacing
		var angle_vector = (Vector2(radius * cos(angle), - radius * sin(angle)))
		amount_sprite.position = angle_vector
		#amount_sprite.rotation = PI - angle
		amount_sprite.texture = load("res://assets/images/ui/orb_count.png")
		add_child(amount_sprite)
	
	if prev_section != null:
		if prev_section.active:
			section.unlocked = true


func _on_TextureButton_mouse_entered():
	get_parent().get_parent().showCard(rect_global_position + Vector2(126,0), card_info, max(proficiency-1,0))


func _on_TextureButton_mouse_exited():
	get_parent().get_parent().hideCard()

func setIcon(path):
	get_node("Icon").texture = load(path)
