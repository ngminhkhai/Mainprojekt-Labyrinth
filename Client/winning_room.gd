extends Control
onready var winner_list = $CenterContainer/VBoxContainer/CenterContainer/VBoxContainer/ItemList
onready var camera = $Camera2D
onready var mainMenu = preload("res://TitleMenu.tscn").instance()

var winner = Server.winners

func _ready():
	clear_rank()

func _process(_delta):
	if visible :
		camera.current = true

func refresh_winners(winners):
	clear_rank()
	for winner_id in winners :
		var winname = Server.winners[winner_id]["players_name"]
		winner_list.add_item(winname, null, false)
		print("winner is : " + winname )


func _on_quitbtn_pressed():
	clear_rank()
	get_tree().quit()


func _on_menubutton_pressed():
	get_tree().paused=false
	Server.end_game()
	
		
func clear_rank():
	winner_list.clear()
