extends Control

onready var player_name = $CenterContainer/VBoxContainer/GridContainer/NameTextbox
onready var selected_IP = $CenterContainer/VBoxContainer/GridContainer/IPTextbox
onready var selected_port = $CenterContainer/VBoxContainer/GridContainer/PortTextbox
onready var join_button = $CenterContainer/VBoxContainer/Join






func _ready():
	player_name.text = Save.save_data ["players_name"]
	selected_IP.text = Server.DEFAULT_IP
	selected_port.text = str(Server.DEFAULT_PORT)
	
func _on_Join_pressed():
	Server.selected_IP = selected_IP.text
	Server.selected_port = int(selected_port.text)
	Server._connect_to_server()
	join_button.disabled=true
	join_button.text = "Connecting..."
	
	#show_waiting_room()


func _on_NameTextbox_text_entered(_new_text):
	Save.save_data["players_name"] = player_name.text
	Save.save_game()
	
	



#func _on_RdyButton_pressed():
#	Server.load_game()
#	Save.save_data.clear()
#	ai_select.disabled=true
#	ready_btn.disabled=true



