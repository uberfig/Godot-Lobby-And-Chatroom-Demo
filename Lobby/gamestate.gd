extends Node

#this is a singleton so it can be easily accessed by all scripts at any time

#this singleton is used to stpre all player data and some imprtant functions
#as well as connect peers and handle all cases that could arrise such as 
#a player joining, leaving, and begining the game


# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 43666

# Max number of players.
const MAX_PEERS = 6

var peer = null

# Name for my player.
var player_name = ""

# Names for remote players in id:name format.
var players = {}
var players_ready = []

# Signals to let lobby GUI know what's going on.
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

# Callback from SceneTree.
func _player_connected(id):
	# Registration of a client beings here, tell the connected player that we are here.
	rpc_id(id, "register_player", player_name)


# Callback from SceneTree.
#this is for if a peer disconnects, it tells if they are a standard peer or a server, and ends game if they are server
func _player_disconnected(id):
	if has_node("/root/ChatRoom"): # room is in progress.
		if get_tree().is_network_server():
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
	else: # Game is not in progress.
		# Unregister this player.
		unregister_player(id)
		get_tree().network_peer = null


# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	# We just connected to a server
	emit_signal("connection_succeeded")


# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")


# Lobby management functions.

remote func register_player(new_player_name):
	var id = get_tree().get_rpc_sender_id()
	print(id)
	players[id] = new_player_name
	emit_signal("player_list_changed")


func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")



remote func pre_start_game():
	# open the chatroom and hide the lobby
	var ChatRoom = load("res://ChatRoom/ChatRoom.tscn").instance()
	get_tree().get_root().add_child(ChatRoom)

	get_tree().get_root().get_node("Lobby").hide()



remote func post_start_game():
	get_tree().set_pause(false) # Unpause and start the room


remote func ready_to_start(id):
	assert(get_tree().is_network_server())
	
	if not id in players_ready:
		players_ready.append(id)
	
	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()


func host_game(new_player_name):
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(peer)


func join_game(ip, new_player_name):
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)


func get_player_list():
	return players.values()


func get_player_name():
	return player_name


func begin_game():
	assert(get_tree().is_network_server())
	for p in players:
		rpc_id(p, "pre_start_game")
	
	pre_start_game()


remotesync func end_game():
	if has_node("/root/ChatRoom"): # room is in progress.
		
		get_node("/root/ChatRoom").queue_free() #room node is cleared and user is returned to the lobby
	
	emit_signal("game_ended")
	players.clear()
	get_tree().network_peer = null #ends the connection


func _ready(): #connect signals to self
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_ok")
# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connected_fail")
# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")
