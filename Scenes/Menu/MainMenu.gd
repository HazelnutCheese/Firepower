extends Node

onready var _playButton : Button = get_node("MarginContainer/MarginContainer/Menu Options/PlayButton")
onready var _settingsButton : Button = get_node("MarginContainer/MarginContainer/Menu Options/SettingsButton")
onready var _exitButton : Button = get_node("MarginContainer/MarginContainer/Menu Options/ExitButton")

onready var _settingsMenu : Popup = get_node("SettingsMenu")

onready var _quitDialog : ConfirmationDialog = null

func _playButton_Pressed():
	get_tree().change_scene("res://scenes/test_farm.tscn")

func _settingsButton_Pressed():
	_settingsMenu.show()

func _exitButton_Pressed():
	get_tree().quit()

func _ready():	
	_playButton.connect("pressed", self, "_playButton_Pressed")
	_settingsButton.connect("pressed", self, "_settingsButton_Pressed")
	_exitButton.connect("pressed", self, "_exitButton_Pressed")

func _input(event):
	if Input.is_action_just_pressed("ingame_MenuButton"):
		if(_settingsMenu.visible):
			_settingsMenu.hide()
		elif(_quitDialog == null):
			_quitGame()
		elif(_quitDialog != null):
			_quitCancelled()

func _quitGame():
	_quitDialog = ConfirmationDialog.new()
	_quitDialog.set_name("confirmExitDialog")
	add_child(_quitDialog)
	_quitDialog.window_title = "Are you sure?"
	_quitDialog.popup_exclusive = true
	_quitDialog.get_ok().connect("pressed", self, "_quitPressed")
	_quitDialog.get_cancel().connect("pressed", self, "_quitCancelled")
	_quitDialog.popup_centered()

func _quitPressed():
	get_tree().quit()

func _quitCancelled():
	remove_child(_quitDialog)
	_quitDialog = null
