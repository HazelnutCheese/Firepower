extends Node

# Networking
const MAX_PLAYERS = 4
var _player_info = {}
var _networkId = -1

var playerScene = load("res://Scenes/Player/Player.tscn")
var DemoScene = load("res://Scenes/MainScene.tscn")
var menuScene = load("res://Scenes/Menu/MainMenu.tscn")

func _ready():
	# Networking Signal Connects
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("connection_failed", self, "_connection_failed")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _physics_process(_delta):
	if get_tree().is_network_server():
		_updateWorldState(_player_info)
		rpc_unreliable("_updateWorldState", _player_info)

# Called on both clients and server when a peer connects. 
func _player_connected(id):
	if get_tree().is_network_server():
		print("player ",id," connected")
		_player_info[id] = "Player" + str(id)
	else:
		_networkId = get_tree().get_network_unique_id()

# Called on both clients and server when a peer disconnects. 
func _player_disconnected(id):
	if get_tree().is_network_server():
		print("player ",id," disconnected")
		_player_info.erase(id) # Erase player from info.
		_removePlayer(id)
		rpc_id(id, "_removePlayer")
	else:
		print("You disconnected from the server")

# Only for clients (not server).
func _connected_to_server():
	print("_connected_to_server")
	var world = DemoScene.instance()
	get_tree().get_root().add_child(world)
	get_tree().get_root().get_node("MainMenu").queue_free()
	pass

# Only for clients (not server).
func _connection_failed():
	print("_connection_failed")
	var mainMenu = menuScene.instance()
	get_tree().get_root().add_child(mainMenu)
	var control = get_tree().get_root().get_node("Control")
	if(control != null):
		control.queue_free()

# Only for clients (not server).
func _server_disconnected():
	print("_server_disconnected")
	var mainMenu = menuScene.instance()
	get_tree().get_root().add_child(mainMenu)
	get_tree().get_root().get_node("Control").queue_free()

# Signals from buttons
func _hostServer(port):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	var world = DemoScene.instance()
	get_tree().get_root().add_child(world)
	get_tree().get_root().get_node("MainMenu").queue_free()
	_networkId = 1
	_player_info[1] = "Player1"
	_addPlayer(1, "Player1")

func _joinServer(ipAddress, port):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ipAddress, port)
	get_tree().set_network_peer(peer)
	
func _endConnection():
	var mainMenu = menuScene.instance()
	get_tree().get_root().add_child(mainMenu)
	get_tree().get_root().get_node("Control").queue_free()
	get_tree().set_network_peer(null)
	_networkId = -1

remote func _updateWorldState(playerInfo):
	var world = get_tree().get_root().get_node("Control/GameViewportContainer/Viewport/testScene")
	for n in playerInfo:
		var player = world.get_node(playerInfo[n])
		if(player == null):
			_addPlayer(n, playerInfo[n])

# Adds a player to the scene on both the server and the clients
func _addPlayer(id, name):
	var player = playerScene.instance()	
	# The id must be unique
	player.set_name(name)	
	# Add the player to the scene
	get_tree().get_root().get_node("Control/GameViewportContainer/Viewport/testScene").add_child(player)
	# Call the setup
	player._setup(id)

remote func _removePlayer(id):
	var playerName = "Player" + str(id)
	# Remove the player from the scene
	var player = get_tree().get_root().get_node("Control/GameViewportContainer/Viewport/testScene/" + playerName)
	player.queue_free()
	print("Player" + str(id) + " removed")

