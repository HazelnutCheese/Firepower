extends Node

var _serverSidePlayersInputs = {}
var _localInputDict = {}

func _ready():
	_localInputDict = _createInputDict()

func _createInputDict():
	return { 
	"cameraY" : 0.0,
	"inGame_Jump" : false,
	"inGame_Attack1" : false,
	"inGame_MoveForward" : false,
	"inGame_MoveBackward" : false,
	"inGame_StrafeLeft" : false,
	"inGame_StrafeRight" : false,
	"inGame_Sprint" : false,
	"inGame_Roll" : false }

func _getInputs(id):
	if not _serverSidePlayersInputs.has(id):
		_serverSidePlayersInputs[id] = _createInputDict()	
	return _serverSidePlayersInputs[id]

func _updateRemoteInput(networkId, inputName, newValue):
	if get_tree().is_network_server():
		_getInputs(networkId)[inputName] = newValue

func _updateInput(inputName, newValue):
	var currentValue = _localInputDict[inputName]
	if(newValue == currentValue):
		return
	_localInputDict[inputName] = newValue
	if get_tree().is_network_server():
		_getInputs(1)[inputName] = newValue
	elif(ServerClient._networkId > 1):
		rpc_unreliable_id(1, "_serverRecieveInputs", inputName, newValue)

remote func _serverRecieveInputs(inputName, newValue):
	var rpcId = get_tree().get_rpc_sender_id()
	_getInputs(rpcId)[inputName] = newValue

func _clearInputs():
	_localInputDict["inGame_MoveForward"] = false
	_localInputDict["inGame_MoveBackward"] = false
	_localInputDict["inGame_StrafeLeft"] = false
	_localInputDict["inGame_StrafeRight"] = false
	
func _unhandled_input(event):
	if (event.is_action_pressed("inGame_MoveForward")):
		_updateInput("inGame_MoveForward", true)
	elif (event.is_action_pressed("inGame_MoveBackward")):
		_updateInput("inGame_MoveBackward", true)
	elif (event.is_action_pressed("inGame_StrafeLeft")):
		_updateInput("inGame_StrafeLeft", true)
	elif (event.is_action_pressed("inGame_StrafeRight")):
		_updateInput("inGame_StrafeRight", true)
	elif (event.is_action_released("inGame_MoveForward")):
		_updateInput("inGame_MoveForward", false)
	elif (event.is_action_released("inGame_MoveBackward")):
		_updateInput("inGame_MoveBackward", false)
	elif (event.is_action_released("inGame_StrafeLeft")):
		_updateInput("inGame_StrafeLeft", false)
	elif (event.is_action_released("inGame_StrafeRight")):
		_updateInput("inGame_StrafeRight", false)
	elif (event.is_action_pressed("inGame_Jump")):
		_updateInput("inGame_Jump", true)
	elif (event.is_action_released("inGame_Jump")):
		_updateInput("inGame_Jump", false)
	elif (event.is_action_pressed("inGame_Attack1")):
		_updateInput("inGame_Attack1", true)
	elif (event.is_action_released("inGame_Attack1")):
		_updateInput("inGame_Attack1", false)
	elif (event.is_action_pressed("inGame_Sprint")):
		_updateInput("inGame_Sprint", true)
	elif (event.is_action_released("inGame_Sprint")):
		_updateInput("inGame_Sprint", false)
	elif (event.is_action_pressed("inGame_Roll")):
		_updateInput("inGame_Roll", true)
	elif (event.is_action_released("inGame_Roll")):
		_updateInput("inGame_Roll", false)
