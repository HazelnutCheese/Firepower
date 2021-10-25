extends Control

onready var _gameViewport = $GameViewportContainer/Viewport
onready var _inGameMenu : Popup = $InGameMenu

func _ready():
	# Required to change the 3D viewport's size when the window is resized.
	# warning-ignore:return_value_discarded
	get_viewport().connect("size_changed", self, "_root_viewport_size_changed")

# This is done to handle multiple resolutions without losing quality.
func _root_viewport_size_changed():
	_gameViewport.size = get_viewport().size * (Configuration._renderScale / 100)	



