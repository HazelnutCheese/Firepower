extends Node

onready var _playButton : Button = get_node("MarginContainer/MarginContainer/Menu Options/PlayButton")
onready var _hostButton : Button = get_node("MarginContainer/MarginContainer/Menu Options/HostButton")
onready var _joinButton : Button = get_node("MarginContainer/MarginContainer/Menu Options/JoinButton")
onready var _settingsButton : Button = get_node("MarginContainer/MarginContainer/Menu Options/SettingsButton")
onready var _exitButton : Button = get_node("MarginContainer/MarginContainer/Menu Options/ExitButton")

onready var _joinIpTextEdit : TextEdit = get_node("MarginContainer/MarginContainer/Menu Options/JoinIpTextEdit")
onready var _joinPortTextEdit : TextEdit = get_node("MarginContainer/MarginContainer/Menu Options/JoinPortTextEdit")

onready var _settingsMenu : Popup = get_node("SettingsMenu")

onready var _quitDialog : ConfirmationDialog = null

func _ready():	
	# warning-ignore:return_value_discarded
	_playButton.connect("pressed", self, "_playButton_Pressed")
	# warning-ignore:return_value_discarded
	_hostButton.connect("pressed", self, "_hostButton_Pressed")
	# warning-ignore:return_value_discarded
	_joinButton.connect("pressed", self, "_joinButton_Pressed")
	# warning-ignore:return_value_discarded
	_settingsButton.connect("pressed", self, "_settingsButton_Pressed")
	# warning-ignore:return_value_discarded
	_exitButton.connect("pressed", self, "_exitButton_Pressed")

func _input(_event):
	if Input.is_action_just_pressed("ingame_MenuButton"):
		if(_settingsMenu.visible):
			_settingsMenu.hide()
		elif(_quitDialog == null):
			_quitGame()
		elif(_quitDialog != null):
			_quitCancelled()

func _playButton_Pressed():
	get_tree().change_scene("res://scenes/MainScene.tscn")

func _hostButton_Pressed():
	ServerClient._hostServer(int(_joinPortTextEdit.text))
	
func _joinButton_Pressed():
	ServerClient._joinServer(_joinIpTextEdit.text, int(_joinPortTextEdit.text))

func _settingsButton_Pressed():
	_settingsMenu.show()

func _exitButton_Pressed():
	get_tree().quit()

func _quitGame():
	_quitDialog = ConfirmationDialog.new()
	_quitDialog.set_name("confirmExitDialog")
	add_child(_quitDialog)
	_quitDialog.window_title = "Are you sure?"
	_quitDialog.popup_exclusive = true
	# warning-ignore:return_value_discarded
	_quitDialog.get_ok().connect("pressed", self, "_quitPressed")
	# warning-ignore:return_value_discarded
	_quitDialog.get_cancel().connect("pressed", self, "_quitCancelled")
	_quitDialog.popup_centered()

func _quitPressed():
	get_tree().quit()

func _quitCancelled():
	remove_child(_quitDialog)
	_quitDialog = null
