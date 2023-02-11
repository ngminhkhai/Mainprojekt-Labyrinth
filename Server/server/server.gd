extends Node


var network = NetworkedMultiplayerENet.new()
var port = 3234
var max_players = 20

var players = {}
var ready_players = 0
var winners = {}
var level = 1

func _ready():
	start_server()
		
func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	network.connect("peer_connected", self, "_player_connected")
	network.connect("peer_disconnected", self, "_player_disconnected")
	
	print("Server Started")
	
func _player_connected(player_id):
	print("Player: " + str(player_id) + " Connected")
	players [player_id] = false
	
func _player_disconnected(player_id):
	print("Player: " + str(player_id) + " Disconnected")
	if get_tree().get_root().has_node("game"):
		get_tree().get_root().get_node("game").delete_player(player_id)
	if get_tree().get_root().has_node("Level2"):
		get_tree().get_root().get_node("Level2").delete_player(player_id)
	if get_tree().get_root().has_node("Level3"):
		get_tree().get_root().get_node("Level3").delete_player(player_id)
	if get_tree().get_root().has_node("Level4"):
		get_tree().get_root().get_node("Level4").delete_player(player_id)
	players.erase(player_id)
	rset("players", players)
	rpc("update_waiting_room")
	print(players.empty())
	if players.empty():
		game_ended()
	
remote func send_player_info(id, player_data):
	players[id] = player_data
	rset("players", players)
	rpc("update_waiting_room")


remote func player_reached_goal(id,player_data):
	winners[id] = player_data
	rset("winners", winners)
	rpc("update_winning_room",id,player_data)
	
remote func playerRdy(player_id):
	players [player_id] =true
	
remote func load_world():
	ready_players +=1
	if players.size()>1 and ready_players >= players.size() :
		rpc("start_game")
		ready_players = 0
		print("starting game")
		var game = preload("res://game/game.tscn").instance()
		if level == 2:
			game = preload("res://game/Level2.tscn").instance()
		if level == 3:
			game = preload("res://game/Level3.tscn").instance()
		if level == 4:
			game = preload("res://game/Level4.tscn").instance()
		get_tree().get_root().add_child(game)
		get_tree().set_refuse_new_network_connections(true)
		

remote func update_level_all(num):
	level = num
	rpc("update_level_server",num)
	
func game_ended():
	if has_node("/root/game"):
		print("game end")
		get_tree().get_root().get_node("game").queue_free()
		winners.clear()
	if has_node("/root/Level2"):
		print("game end")
		get_tree().get_root().get_node("Level2").queue_free()
		winners.clear()
	if has_node("/root/Level3"):
		print("game end")
		get_tree().get_root().get_node("Level3").queue_free()
		winners.clear()
	if has_node("/root/Level4"):
		print("game end")
		get_tree().get_root().get_node("Level4").queue_free()
		winners.clear()
	players.clear()
	get_tree().set_refuse_new_network_connections(false)
