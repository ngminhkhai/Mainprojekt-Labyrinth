extends Button



func _on_level1button_pressed():
	#$CanvasLayer3/TitleMenu.visible = false
	get_tree().change_scene("res://lobby/Lobby.tscn")
