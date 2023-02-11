extends Node
#saving ai_num from client input
#ai is being created but it moves differently in every client instance? 
const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 3234

var network = NetworkedMultiplayerENet.new()
var selected_IP
var selected_port
var local_player_id = 0
var ai = false
var difficulty = -2
var game_ongoing = false
sync var players = {}
var player_data = {}
sync var winners = {}
sync var level = 1
var connected = false
var disconnected = false


func _process(delta):
	if disconnected :
		if game_ongoing:
			end_game()
		var warning = preload("res://Warning.tscn").instance()
		get_tree().get_root().add_child(warning)
		warning.visible=true


func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

	
func _connect_to_server():
	get_tree().connect("connected_to_server", self, "_connected_ok")
	network.create_client(selected_IP , selected_port)
	get_tree().set_network_peer(network)
	
func _player_connected(id):
	print("Player: " + str(id) + " Connected")
	connected = true

	
	
func _player_disconnected(id):
	print("Player: " + str(id) + " Disconnected")
	if get_tree().get_root().has_node("game"):
		get_tree().get_root().get_node("game").delete_player(id)
	if get_tree().get_root().has_node("Level2"):
		get_tree().get_root().get_node("Level2").delete_player(id)
	if get_tree().get_root().has_node("Level3"):
		get_tree().get_root().get_node("Level3").delete_player(id)
	if get_tree().get_root().has_node("Level4"):
		get_tree().get_root().get_node("Level4").delete_player(id)
	
	
	
func _connected_ok():
	print(network.get_connection_status())
	print("Successfully connected to server")
	register_player()
	rpc_id(1, "send_player_info", local_player_id, player_data)
	get_tree().change_scene("res://Levelinteface/Levelinterface.tscn")
	

func _connected_fail():
	get_tree().disconnect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	network.create_client(selected_IP , selected_port)
	get_tree().set_network_peer(network)
	print("Failed to connect")


func _server_disconnected():
	disconnected = true
	print("Server Disconnected")

func register_player():
	local_player_id = get_tree().get_network_unique_id()
	player_data = Save.save_data
	players[local_player_id] = player_data

sync func update_waiting_room():
	get_tree().call_group("WaitingRoom", "refresh_players", players)

func load_game():
	rpc_id(1, "load_world")

sync func start_game():
	game_ongoing = true
	print("server: " + str(difficulty))
	var game = preload("res://game/game.tscn").instance()
	if level==2:
		game = preload("res://game/Level2.tscn").instance()
	if level==3:
		game = preload("res://game/Level3.tscn").instance()
	if level==4:
		game = preload("res://game/Level4.tscn").instance()
	print("final level: "+ str(level))
	get_tree().get_root().add_child(game)
	get_tree().get_root().get_node("Levelinterface").queue_free()
	get_tree().set_refuse_new_network_connections(true)

	
func register_winner():
	winners[local_player_id] = player_data
	rpc_id(1,"player_reached_goal",local_player_id,player_data)


sync func update_winning_room(id,player_data):
	if id != local_player_id:
		winners[local_player_id] = player_data
	get_tree().call_group("winningRoom","refresh_winners", winners)

sync func update_level_server(num):
	print("changed to level " + str(level))
	level=num
	
func update_level():
	print(" level " + str(level)+"wanted")
	rpc_id(1,"update_level_all",level)

func end_game():
	game_ongoing = false
	var game
	print("player ended game")
	if has_node("/root/game"):
		game = get_node("/root/game")
	elif has_node("/root/Level2"):
		game = get_node("/root/Level2")
	elif has_node("/root/Level3"):
		game = get_node("/root/Level3")
	elif has_node("/root/Level4"):
		game = get_node("/root/Level4")
	game.queue_free()
	get_tree().change_scene("res://TitleMenu.tscn")
	get_tree().disconnect("connected_to_server",self,"_connected_ok")
	get_tree().set_network_peer(null)
	network.close_connection()
