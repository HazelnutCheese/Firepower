extends Popup

onready var _screenModeOptions : OptionButton = get_node("MarginContainer/VBoxContainer/MarginContainer/TabContainer/Display/VboxOptions/ScreenMode/ScreenModeOptions")
onready var _windowSizeOptions : OptionButton = get_node("MarginContainer/VBoxContainer/MarginContainer/TabContainer/Display/VboxOptions/WindowSize/WindowSizeOptions")
onready var _borderless : CheckBox = get_node("MarginContainer/VBoxContainer/MarginContainer/TabContainer/Display/VboxOptions/Borderless")
onready var _renderScaleSlider : HSlider = get_node("MarginContainer/VBoxContainer/MarginContainer/TabContainer/Display/VboxOptions/RenderScale/HboxContainer/RenderScaleSlider")
onready var _renderScaleText : Label = get_node("MarginContainer/VBoxContainer/MarginContainer/TabContainer/Display/VboxOptions/RenderScale/HboxContainer/RenderScaleTextValue")
onready var _renderedResolutionText : Label = get_node("MarginContainer/VBoxContainer/MarginContainer/TabContainer/Display/VboxOptions/RenderScale/HBoxContainer/RenderedResolutionTextValue")
onready var _applyButton : Button = get_node("MarginContainer/VBoxContainer/MarginContainer/TabContainer/Display/VboxOptions/ApplyButton")
onready var _backButton : Button = get_node("MarginContainer/VBoxContainer/BackButtonContainer/BackButton")

# Viewport
onready var _gameViewport : Viewport = get_tree().get_root().get_node("Control/GameViewportContainer/Viewport")

# Called when the node enters the scene tree for the first time.
func _ready():
	_setup_ScreenModeOptions()	
	_setup_WindowSizeOptions()
	_setup_RenderScaleSlider()

	# warning-ignore:return_value_discarded
	_applyButton.connect("pressed", self, "_applyButton_pressed")
	# warning-ignore:return_value_discarded
	_backButton.connect("pressed", self, "_backButton_pressed")
	
	_screenModeOptions.select(Configuration._windowedMode)
	_screenModeOptions_ItemSelected(Configuration._windowedMode)
	
	if(Configuration._windowedMode):
		_windowSizeOptions.select(Configuration._getWindowSizeAsId())
		
	if(Configuration._windowedMode and Configuration._borderless):
		_borderless.pressed = true	

	_renderScaleSlider.value = Configuration._renderScale
	_renderScaleSlider_ValueChanged(Configuration._renderScale)
	
	if(not Configuration._windowedMode):
		set_fullscreen()
	else:
		set_windowed()

func _setup_ScreenModeOptions():	
	_screenModeOptions.add_item("Fullscreen")
	_screenModeOptions.add_item("Windowed")
	# warning-ignore:return_value_discarded
	_screenModeOptions.connect("item_selected", self, "_screenModeOptions_ItemSelected")

func _setup_WindowSizeOptions():
	for displayOption in Configuration._windowSizeOptions:
		_windowSizeOptions.add_item(displayOption)

func _setup_RenderScaleSlider():
	# warning-ignore:return_value_discarded
	_renderScaleSlider.connect("value_changed", self, "_renderScaleSlider_ValueChanged")

func _screenModeOptions_ItemSelected(selectedIndex):
	if(selectedIndex == 0):
		_windowSizeOptions.disabled = true
		_borderless.disabled = true
		_borderless.pressed = false
	else:
		_windowSizeOptions.disabled = false
		_borderless.disabled = false

func _renderScaleSlider_ValueChanged(newValue):
	_renderScaleText.text = str(newValue) + "%"
	var renderedWidth = 1920 * (newValue / 100)
	var renderedHeight = 1080 * (newValue / 100)
	_renderedResolutionText.text = str(renderedWidth) + "x" + str(renderedHeight)

func _applyButton_pressed():
	Configuration._windowedMode = _screenModeOptions.selected
	Configuration._windowSize = _windowSizeOptions.get_item_text(_windowSizeOptions.selected)
	if(Configuration._windowSize == "Custom"):
		var windowSize = OS.get_window_size()
		Configuration._windowSizeWidth = windowSize.x
		Configuration._windowSizeHeight = windowSize.y
	else:
		Configuration._windowSizeWidth = 0
		Configuration._windowSizeHeight = 0	
	Configuration._borderless = _borderless.pressed
	Configuration._renderScale = _renderScaleSlider.value
	Configuration._save()
	
	if(not Configuration._windowedMode):
		set_fullscreen()
	else:
		set_windowed()

func _backButton_pressed():
	self.hide()

func set_fullscreen():
	OS.set_window_fullscreen(true)
	OS.set_borderless_window(false)
	if(_gameViewport != null):
		_gameViewport.size = get_viewport().size * (Configuration._renderScale / 100)

func set_windowed():	
	var windowSizeOption = Configuration._getWindowSizeAsId()
	if(windowSizeOption == 0):
		return
		
	var screen_size = OS.get_screen_size(0)
	var selectedDimensions = Configuration._windowSize.split("x")
	var selectedX = float(selectedDimensions[0])
	var selectedY = float(selectedDimensions[1])
	var newSize = Vector2(selectedX, selectedY)
	
	var window_x = (screen_size.x / 2) - (newSize.x / 2)
	var window_y = (screen_size.y / 2) - (newSize.y / 2)
	OS.set_borderless_window(Configuration._borderless)
	OS.set_window_fullscreen(false)
	OS.set_window_position(Vector2(window_x, window_y))
	OS.set_window_size(newSize)
	if(_gameViewport != null):
		_gameViewport.size = get_viewport().size * (Configuration._renderScale / 100)
