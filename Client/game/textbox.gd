extends CanvasLayer

onready var chest_buttons = $TextboxCointainer/MarginContainer/HBoxContainer/VBoxContainer
onready var riddle_buttons = $TextboxCointainer/MarginContainer/HBoxContainer/Riddle
onready var label = $TextboxCointainer/MarginContainer/HBoxContainer/Text
onready var riddle_answer_buttons = $TextboxCointainer/MarginContainer/HBoxContainer/AnswerOptions
onready var got_it_button = $TextboxCointainer/MarginContainer/HBoxContainer/GotIt

signal yes_chest
signal no_chest
signal yes_Riddle
signal no_Riddle

var buttons_just_visible = false
var speed_up = 1.0

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") and $Tween.is_active(): 
		speed_up= speed_up*2
		$Tween.playback_speed = speed_up
	if chest_buttons.visible and Input.is_action_just_pressed("ui_accept"):
		print("accept button")
	if buttons_just_visible and chest_buttons.visible :
		chest_buttons.get_child(0).grab_focus()
		buttons_just_visible = false
	if buttons_just_visible and riddle_buttons.visible :
		riddle_buttons.get_child(0).grab_focus()
		buttons_just_visible = false
	if buttons_just_visible and riddle_answer_buttons.visible :
		riddle_answer_buttons.get_child(0).grab_focus()
		buttons_just_visible = false
	if got_it_button.visible:
		got_it_button.grab_focus()
func _on_Yes_pressed():
	chest_buttons.hide()
	emit_signal("yes_chest")


func _on_No_pressed():
	chest_buttons.hide()
	emit_signal("no_chest")
	


func _on_Answer_pressed():
	riddle_buttons.hide()
	emit_signal("yes_Riddle")


func _on_NAnswer_pressed():
	riddle_buttons.hide()
	emit_signal("no_Riddle")
