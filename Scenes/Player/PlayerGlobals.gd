extends Node

var playerList = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _addPlayer(player, playerId):
	playerList[playerId] = player

func _getPlayer(playerId):
	if(playerList.has(playerId)):
		return playerList[playerId]
	return null
