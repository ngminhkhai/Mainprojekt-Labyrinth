extends Node2D


remote func remove_chest(id):
	rpc("removes_chest",id)
