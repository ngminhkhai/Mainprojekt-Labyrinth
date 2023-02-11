extends Popup

onready var player_list = $CenterContainer/VBoxContainer/CenterContainer/ItemList
onready var drop_dowm_difficulty = $CenterContainer/VBoxContainer/HBoxContainer/Difficulty



func _ready():
	player_list.clear()
	add_items()
	drop_dowm_difficulty.selected = 0
	

func refresh_players(players):
	player_list.clear()
	for player_id in players:
		var player = players[player_id]["players_name"]
		player_list.add_item(player, null, false)




func _on_Quitbtn_pressed():
	get_tree().quit()


func _on_AI_pressed():
	Server.ai = !Server.ai
	Server.difficulty = drop_dowm_difficulty.selected
	drop_dowm_difficulty.visible = !drop_dowm_difficulty.visible
	

func add_items():
	drop_dowm_difficulty.add_item("easy")
	drop_dowm_difficulty.add_item("medium")
	drop_dowm_difficulty.add_item("hard")



func _on_Difficulty_item_selected(index):
	Server.difficulty = index
