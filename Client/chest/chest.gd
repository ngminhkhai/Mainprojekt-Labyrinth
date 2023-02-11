extends Area2D


var PENALTY = 1
var BONUS = -1
var USED = false
var currently_used = false
var current_user 
onready var shape = $CollisionShape2D

func _ready():
	pass

func _process(_delta):
	if(currently_used or visible == false):
		shape.disabled = true
	else:
		shape.disabled = false
	if(USED):
		get_parent().remove_child(self)




func _on_Chest_body_entered(body):
	print(USED)
	if body is KinematicBody2D:
		if body.is_ai:
			return
		print(body)
		current_user=body
		currently_used = true
		body.chest_found = 1
		body.current_chest = str(self)
		print(body.chest_found)
		print(self)
		print(body.current_chest)


func _on_Chest_body_exited(body):
	if body==current_user:
		currently_used = false

