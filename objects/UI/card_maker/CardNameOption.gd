extends OptionButton

class_name CardNameOption

var list:Array


# Called when the node enters the scene tree for the first time.
func _ready():
	hint_tooltip = BattleDictionary.valid_parameters[BattleDictionary.PARAMETER.CARD_NAME][1]
	var card_list = CardLoader.loadCardList(true)
	list = card_list
	for i in card_list.size():
		add_item(card_list[i])

func loadValues(values:Array):
	select(CardLoader.loadCardList(true).find(values[1]))

func saveValues() -> String:
	return get_item_text(selected)

func get_class() -> String:
	return "UnitNameOption"
