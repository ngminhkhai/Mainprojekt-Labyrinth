extends KinematicBody2D

const CHAR_READ_RATE = 0.05
const line1 = "You've found a chest, do you want to open it?"
const line2 = "It seems like you lost your way, help me solve this riddle and I will help you escape this maze."

const is_ai = false

export var move_speed = 150

onready var player_label=$Label
onready var camera = $Camera2D
onready var label = $Textbox/TextboxCointainer/MarginContainer/HBoxContainer/Text
onready var timer = $CanvasLayer/Timer
onready var textbox_riddle_answers = $Textbox/TextboxCointainer/MarginContainer/HBoxContainer/AnswerOptions
onready var boon_timer = $Timer
onready var player_screen = $CanvasLayer

var current_chest = 0
var velocity = Vector2 (0,0)
var chest_found = 0
var met_old_man = false
var solve_riddle = false
var riddle_solved = false
var riddle_not_solved = false
var crossed_finishline = false
var old_man
var riddle = "I fly when I'm born, lie down when I'm alive and run when I'm dead. What am I?"
var answers = ["A SNOWFLAKE","A BIRD","A LEAVE","A FEATHER"]
var correct_answer = ""
var boon_running = false
var color = Color(1,0,0)
signal tell_chest_action

func _ready():
	player_label.set_as_toplevel(true)
	set_player_name()
	old_man = get_tree().get_nodes_in_group("Oldman")[0]
	
		
func _process(_delta):
	if Server.game_ongoing:
		if is_network_master():
			player_screen.visible = true
			if(chest_found==1):
				chest_found = 0
				print(str(self) + "found Chest")
				open_chest()
			elif(met_old_man):
				met_old_man_fun()
			else:
				leave()
			camera.current = true
			set_modulate(color)
			player_label.rect_position = Vector2(position.x-40,position.y-60)
			if (Input.is_action_pressed("ui_left")):
				#rpc_unreliable("move","x",-move_speed)
				move("x",-move_speed)
			if (Input.is_action_pressed("ui_right")):
				#rpc_unreliable("move","x",move_speed)
				move("x",move_speed)
			if (Input.is_action_pressed("ui_up")):
				#rpc_unreliable("move","y",-move_speed)
				move("y",-move_speed)
			if (Input.is_action_pressed("ui_down")):
				#rpc_unreliable("move","y",move_speed)
				move("y",move_speed)
			if !crossed_finishline:
				rpc_unreliable_id(1,"update_player",global_transform)
		else:
			set_modulate(Color(0.5,0.5,0.5))

func move(var direction, var speed):
	if(direction == "x"):
		velocity.x = speed
	else:
		velocity.y = speed
		
	velocity = move_and_slide(velocity,Vector2.UP)
	velocity.x = lerp(velocity.x,0,0.2)
	velocity.y = lerp(velocity.y,0,0.2)

remote func update_remote_player(transform):
	if not is_network_master():
		global_transform=transform
		player_label.rect_position = Vector2(position.x-40,position.y-60)

func set_player_name():
	player_label.text = Server.players[int(name)]["players_name"]

func open_chest():
	get_tree().paused = true
	$Textbox.visible = true
	$Textbox/FoundChest.visible = true
	add_text(line1)

func add_text(next_text):
	label.text = next_text
	$Textbox/Tween.interpolate_property(label,"percent_visible", 0.0, 1.0,len(next_text)*CHAR_READ_RATE,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	$Textbox/Tween.start()

	
func _on_Tween_tween_completed(_object,_key):
	$Textbox.speed_up = 1.0
	$Textbox.buttons_just_visible = true
	if met_old_man and solve_riddle:
		textbox_riddle_answers.show()
	elif met_old_man:
		$Textbox/TextboxCointainer/MarginContainer/HBoxContainer/Riddle.show()
	elif riddle_solved :
		riddle_solved = false
		$Textbox/TextboxCointainer/MarginContainer/HBoxContainer/GotIt.visible = true
	elif riddle_not_solved:
		print("answered wrong")
		riddle_not_solved=false
		$Textbox/TextboxCointainer/MarginContainer/HBoxContainer/GotIt.text = "Skip"
		$Textbox/TextboxCointainer/MarginContainer/HBoxContainer/GotIt.visible = true
	else:
		$Textbox/TextboxCointainer/MarginContainer/HBoxContainer/VBoxContainer.show()

func leave():
	met_old_man = false
	$Textbox.visible = false
	$Textbox/FoundChest.visible = false
	$Textbox/SusOldMan.visible = false
	get_tree().paused=false


func _on_Textbox_no_chest():
	chest_found = 0
	emit_signal("tell_chest_action",0,current_chest)
	leave()
	

func _on_Textbox_yes_chest():
	penalty()
	emit_signal("tell_chest_action",1,current_chest)
	leave()
	

func met_old_man_fun():
	get_tree().paused = true
	$Textbox.visible = true
	$Textbox/SusOldMan.visible = true
	add_text(line2)


func _on_Textbox_no_Riddle():
	met_old_man = false
	leave()


func _on_Textbox_yes_Riddle():
	solve_riddle = true
	riddle = old_man.selected_riddle[0]
	answers = old_man.selected_riddle.slice(1,4)
	correct_answer =  old_man.selected_riddle[5]
	add_answers()
	add_text(riddle)

func add_answers():
	randomize()
	answers.shuffle()
	var buttonnum = 0
	for i in answers:
		textbox_riddle_answers.get_child(buttonnum).text = i
		buttonnum +=1
	

func _on_Answer1_pressed():
	textbox_riddle_answers.hide()
	checkAnswer(answers[0])


func _on_Answer2_pressed():
	textbox_riddle_answers.hide()
	checkAnswer(answers[1])


func _on_Answer3_pressed():
	textbox_riddle_answers.hide()
	checkAnswer(answers[2])


func _on_Answer4_pressed():
	textbox_riddle_answers.hide()
	checkAnswer(answers[3])

func checkAnswer(answer):
	if answer == correct_answer:
		riddle_solved = true
		old_man.correct_answer =true
		solve_riddle = false
		met_old_man = false
		add_text("You're right. As for your reward. Follow me! ")
	else: 
		print(riddle_not_solved)
		riddle_not_solved = true
		solve_riddle = false
		met_old_man = false
		print(riddle_not_solved)
		add_text("Wrong")

func _on_GotIt_pressed():
	leave()
	$Textbox/TextboxCointainer/MarginContainer/HBoxContainer/GotIt.visible = false
	$Textbox/TextboxCointainer/MarginContainer/HBoxContainer/GotIt.text = "Got it !"

func penalty():
	print("before: "+str(move_speed))
	randomize()
	var num = randi()%2
	boon_timer.start()
	if num == 0:
		move_speed = 80 
		color = Color(0.5,0,0.7)
		print("after: "+str(move_speed))
	else:
		move_speed = 200
		color = Color(0,1,0)
		print("after: "+str(move_speed))


func _on_Timer_timeout():
	move_speed = 150
	color = Color(1,0,0)
	print("final: "+str(move_speed))
