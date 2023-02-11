extends KinematicBody2D

const is_ai = true

export var SPEED = 80


onready var player_label=$Label
onready var camera = $Camera2D
onready var label = $Textbox/TextboxCointainer/MarginContainer/HBoxContainer/Text
onready var nav_agent = $NavigationAgent2D
onready var collision = $CollisionShape2D

var difficulty
var velocity = Vector2.ZERO
var path: Array = []
var levelNavigation: Navigation2D = null
var possible_targets = null
var finishline = null
var current_target = null 
var crossed_finishline = false

func _ready():
	if is_ai:		
		set_collision_mask_bit(3,false)
	player_label.set_as_toplevel(true)
	set_player_name()
	randomize()
	var tree = get_tree()
	if tree.has_group("LevelNavigation"):
		levelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
	if tree.has_group("AI_Targetpositions"):
		possible_targets= tree.get_nodes_in_group("AI_Targetpositions")
	possible_targets.shuffle()
	if difficulty == "hard":
		SPEED = 110
		possible_targets=possible_targets.slice(0,2)
	elif difficulty == "medium":
		SPEED = 95
		possible_targets=possible_targets.slice(0,5)
	if tree.has_group("Finishline"):
		finishline = tree.get_nodes_in_group("Finishline")[0]
		possible_targets.append(finishline)
		possible_targets.shuffle()
		set_target_position()
	print("first :" + current_target.name)

func _physics_process(_delta):
	
	if is_network_master():
		camera.current = true
		set_modulate(Color(1,0,0))
		player_label.rect_position = Vector2(position.x-40,position.y-60)
		var move_direction = global_position.direction_to(nav_agent.get_next_location())
		velocity = move_direction * SPEED
		nav_agent.set_velocity(velocity)
		if ! nav_agent.is_navigation_finished():
			velocity = move_and_slide(velocity)
			velocity.x = lerp(velocity.x,0,0.2)
			velocity.y = lerp(velocity.y,0,0.2)
			rpc_unreliable_id(1,"update_player",global_transform)
		else:
			print("before: "+ current_target.name )
			if !crossed_finishline:
				set_target_position()
				print("after: "+ current_target.name )
	else:
		set_modulate(Color(0.5,0.5,0.5))


remote func update_remote_player(transform):
	if not is_network_master():
		global_transform=transform
		player_label.rect_position = Vector2(position.x-40,position.y-60)

func set_player_name():
	player_label.text = Server.players[int(name)]["players_name"]
	
func set_target_position():
	print("new target")
	current_target = possible_targets.pop_front()
	nav_agent.set_target_location(current_target.global_position)
