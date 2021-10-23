extends Control

# The 3D viewport's scale factor. For instance, 1.0 is full resolution,
# 0.5 is half resolution and 2.0 is double resolution. Higher values look
# sharper but are slower to render. Values above 1 can be used for supersampling
# (SSAA), but filtering must be enabled for supersampling to work.
var scale_factor = 1.0

onready var _gameViewport = $GameViewportContainer/Viewport
onready var _inGameMenu : Popup = $InGameMenu

func _ready():
	#viewport.get_texture().flags = Texture.FLAG_FILTER

	# Required to change the 3D viewport's size when the window is resized.
	# warning-ignore:return_value_discarded
	get_viewport().connect("size_changed", self, "_root_viewport_size_changed")

#func _input(event):
#	if Input.is_action_just_pressed("ingame_MenuButton"):
#		if(_inGameMenu.visible):
#			_gameViewport.set_process_input(false)
#		else:
#			_gameViewport.set_process_input(true)
# Called when the root's viewport size changes (i.e. when the window is resized).
# This is done to handle multiple resolutions without losing quality.
func _root_viewport_size_changed():
	_gameViewport.size = get_viewport().size * (Configuration._renderScale / 100)
