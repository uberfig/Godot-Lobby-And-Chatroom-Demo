extends Control

onready var chatLog = $VBoxContainer/RichTextLabel
onready var inputLabel = $VBoxContainer/HBoxContainer/Label
onready var inputFeild = $VBoxContainer/HBoxContainer/LineEdit


#grabs the player's name from the gamestate singleton
var user_name = gamestate.player_name


func _ready():
	#set the label text to remind the players if they are the server or a peer
	if get_tree().is_network_server():
		$VBoxContainer/HBoxContainer/Label.text = "host"
	else:
		$VBoxContainer/HBoxContainer/Label.text = "member"


remotesync func send_message(username, text):
	#this function is called on the peers and the server when it is called through rpc
	chatLog.bbcode_text += "\n" 
	chatLog.bbcode_text += "[color=#34c5f1]"
	chatLog.bbcode_text += "[" + username + "]:"
	chatLog.bbcode_text += "[/color]"
	chatLog.bbcode_text += text



func _on_LineEdit_text_entered(new_text):
	if new_text != "": #prevents peers from spamming the chat with whitespace, you could add a timer to further prevent spamming
		print(new_text)
		rpc("send_message", user_name, new_text)
		#send_message(user_name, new_text)
		inputFeild.text = "" #clears the text from the input feild 
		inputFeild.release_focus()
