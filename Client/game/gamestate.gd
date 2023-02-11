extends Node2D

const PLAYER = preload("res://player/player.tscn")
const WINNINGROOM = preload("res://winning_room.tscn")

onready var player_spawn = $PlayerSpawn
onready var players = $Players
onready var winningscreen = $CanvasLayer2
onready var oldman = $OldMan
onready var chests = $Chests

var winning_room = WINNINGROOM.instance()
var ai = false
var difficulty 
var game_ended = false 

func _ready():
	print("gamestate: " + str(difficulty))
	ai = Server.ai
	if Server.difficulty != -2:
		if Server.difficulty == 0 :
			difficulty = "easy"
		elif Server.difficulty == 1 :
			difficulty = "medium"
		elif Server.difficulty == 2 :
			difficulty = "hard"
	print(str(player_spawn.position))
	rpc_id(1,"spawn_players", Server.local_player_id)
	
	
remote func spawn_player(id):
	
	var player = PLAYER.instance()
	if ai: 
		print("ich bin eine Ai")
		player.set_script(load("res://player/ai.gd"))
		player.difficulty = difficulty
	elif !player.is_ai:
		player.connect("tell_chest_action",self,"update_chest")
	player.name = str(id)
	players.add_child(player)
	player.set_network_master(id)
	print(str(player_spawn.position))
	player.position = player_spawn.position

func update_chest(used,chest):
	var current_chest = $Chests.get_node(chest)
	if used==0:
		current_chest.currently_used = false
		print("pressed no")
	elif used == 1:
		current_chest.USED = true
		rpc_id(1,"remove_chest", current_chest.global_position)
		print("pressed yes")
		
remote func deletes_chest(positions):
	for chest in chests.get_children():
		if chest.global_position == positions:
			chest.visible = false


func _on_MazeExit_body_entered(body):
	print(body.name)
	#get_tree().paused == true
	#$CanvasLayer2/Control/VBoxContainer/Label.text = Server.players[int(body.name)]["Player_name"] + "  WINS !"
	#$CanvasLayer2/Control.visible = true
	if body is KinematicBody2D :
		body.visible = false 
	if body is KinematicBody2D and body.name != "OldMan":
		body.crossed_finishline = true
	if body.is_network_master():
		Server.register_winner()
		get_tree().paused=true
		winningscreen.add_child(winning_room)
		winningscreen.visible = true
		winning_room.camera.current = true 
	
	
	
func _on_level1button_pressed():
	$CanvasLayer3/TitleMenu.visible = false
	get_tree().change_scene("res://lobby/Lobby.tscn")

func delete_player(id):
	players.get_node(str(id)).queue_free()
