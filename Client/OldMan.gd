extends KinematicBody2D

onready var nav_agent = $NavigationAgent2D
export var SPEED = 100

var velocity = Vector2.ZERO
var path: Array = []
var levelNavigation: Navigation2D = null
var finishline = null
var correct_answer = false
var removed = false
var riddles = []
var selected_riddle = []

func _ready():
	var tree = get_tree()
	if tree.has_group("LevelNavigation"):
		levelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
	if tree.has_group("Finishline"):
		finishline = tree.get_nodes_in_group("Finishline")[0]
	riddles()
	
func _physics_process(_delta):
	if correct_answer:
		$CollisionShape2D.disabled = true
		if !removed :
			remove_child($Area2D)
			removed = true
		if finishline:
			nav_agent.set_target_location(finishline.global_position)
			var move_direction = global_position.direction_to(nav_agent.get_next_location())
			velocity = move_direction * SPEED
			nav_agent.set_velocity(velocity)
			if ! nav_agent.is_navigation_finished():
				move()
	
		
func move():
	velocity = move_and_slide(velocity)

func navigate():
	if path.size() > 0:
		velocity = global_position.direction_to(path[1])*SPEED
		if global_position == path[0]:
			path.pop_front()
	
func generate_path():
	if levelNavigation != null and finishline != null:
		path = levelNavigation.get_simple_path(global_position,finishline.global_position,false)

func _on_Area2D_body_entered(body):
	if body is KinematicBody2D:
		if body.is_ai:
			return
		print(body)
		body.met_old_man = true

func riddles():
	var riddle1 = ["What is the only food that cannot go bad ?","Dark Chocolate","Canned Tuna","Peanut Butter","Honey","Honey"]
	var riddle2 = ["What type of food holds the world record for being the most stolen around the globe?","Wakyu Beef","Cheese","Coffee","Chocolate","Cheese"]
	var riddle3 = ["On average, how many seeds are located on the outside of a strawberry?","100","200","300","400","200"]
	var riddle4 = ["What is the highest-grossing video game franchise to date?","Mario","Pokemon","Cal of Duty","Streetfighter","Pokemon"]
	var riddle5 = ["What year was the first Super Smash Bros. released?","1998","1997","1993","1999","1999"]
	var riddle6 = ["What is the strongest block you can find in Minecraft?","Obsidian","Diamond","Ender Chest","Ancient Debris","Obsidian"]
	var riddle7 = ["What is the longest Mario Kart track?","Luigis Raceway","Koopa Cape Rock","Rock Mountain","3DS Rainbow Road","3DS Rainbow Road"]
	var riddle8 = ["Which of these Pokemon is a first generation starter Pokemon?","Squirtle","Cyndaquil","Litten","Treecko","Squirtle"]
	var riddle9 = ["Which of these best-selling video game franchises without a main character has been sold the most?","Minecraft","Tetris","Need for Speed","The Sims","Tetris"]
	var riddle10 = ["Which was the first video game produced by Nintendo?","Mario Bros","Donkey Kong","Luigis Mansion","EVR Racing","EVR Racing"]
	var riddle11 = ["In what year was the first video game invented?","1958","1969","1943","1962","1958"]
	riddles.append(riddle1)
	riddles.append(riddle2)
	riddles.append(riddle3)
	riddles.append(riddle4)
	riddles.append(riddle5)
	riddles.append(riddle6)
	riddles.append(riddle7)
	riddles.append(riddle8)
	riddles.append(riddle9)
	riddles.append(riddle10)
	riddles.append(riddle11)
	select_riddle()
	
func select_riddle():
	randomize()
	selected_riddle = riddles[randi() % riddles.size()]
