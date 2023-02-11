extends Node2D

const PLAYER = preload("res://player/player.tscn")
const CHEST = preload("res://chest/chest.tscn")

onready var players = $Players
onready var chests = $Chest

remote func spawn_players(id):
	var player = PLAYER.instance()
	player.name = str (id)
	players.add_child(player)
	rpc("spawn_player",id)

remote func spawn_chest():
	var chest = CHEST.instance()
	chest.add_child(chest)
	rpc("spawn_chests")

func delete_player(id):
	players.get_node(str(id)).queue_free()

remote func remove_chest(positions):
	rpc("deletes_chest",positions)
