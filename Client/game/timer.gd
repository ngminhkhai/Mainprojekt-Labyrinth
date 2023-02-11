extends Control

var time_elapsed = 0
var time_passed = 0
var secs = 0
var mins = 0
var Chest_Loot = randi()%2
var USED = false



func _process(delta: float) -> void:
	time_elapsed += delta
	
	secs = fmod(time_elapsed,60)
	mins = fmod(time_elapsed,60*60)/60
	time_passed = "%02d : %02d" % [mins, secs]
	$Label.text = time_passed

func open_chest():
	Chest_Loot = randi()%2
	print(Chest_Loot)
	#Over 1 min
	if(mins>=1): 
		if(Chest_Loot==1):
			mins += 60
		else:
			mins -= 60
		time_elapsed += mins
		USED = false
	else:
		if(Chest_Loot==1):
			mins += 60
			time_elapsed += mins
		else:
			time_elapsed = 0
		USED = false

