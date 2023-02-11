extends Control

onready var waiting_room = $WaitingRoom
onready var ai_select = $WaitingRoom/CenterContainer/VBoxContainer/HBoxContainer/AI
onready var ready_btn = $WaitingRoom/CenterContainer/VBoxContainer/RdyButton

func _ready():
	pass

func show_waiting_room():
	waiting_room.popup_centered()


func _on_Level1btn_pressed():
	Server.level = 1
	Server.update_level()
	show_waiting_room()



func _on_Level2btn_pressed():
	Server.level = 2
	Server.update_level()
	show_waiting_room()



func _on_RdyButton_pressed():
	Server.load_game()
	ai_select.disabled=true
	ready_btn.disabled=true


func _on_Level3bt_pressed():
	Server.level = 3
	Server.update_level()
	show_waiting_room()


func _on_Level4bt_pressed():
	Server.level = 4
	Server.update_level()
	show_waiting_room()
