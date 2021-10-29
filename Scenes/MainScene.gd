extends Control

onready var _gameViewport = $GameViewportContainer/Viewport
onready var _inGameMenu : Popup = $InGameMenu
onready var _localCamera : PlayerCamera = null
onready var _testScene = $"GameViewportContainer/Viewport/testScene"

var playerCameraScene = load("res://Scenes/Player/PlayerCamera.tscn")

func _ready():
	# Required to change the 3D viewport's size when the window is resized.
	# warning-ignore:return_value_discarded
	get_viewport().connect("size_changed", self, "_root_viewport_size_changed")
	
	_localCamera = playerCameraScene.instance()
	_testScene.add_child(_localCamera)
	

# This is done to handle multiple resolutions without losing quality.
func _root_viewport_size_changed():
	_gameViewport.size = get_viewport().size * (Configuration._renderScale / 100)	



