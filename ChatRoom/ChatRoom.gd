extends Control



func _ready():
	#checks if peer is server and disables the endroom button accordingly
	$EndRoom.disabled = not get_tree().is_network_server()




func _on_End_Room_pressed():
	rpc("end_game") #server calls the end game function on peers then ends the game for itself
	gamestate.end_game()


remote func end_game():#called on peers by the server
	gamestate.end_game()
