extends Popup

onready var _screenModeOptions : OptionButton = get_node("MarginContainer/VBoxContainer/MarginContainer/TabContainer/Display/VboxOptions/ScreenModeOptions")
onready var _resolutionOptions : OptionButton = get_node("MarginContainer/VBoxContainer/MarginContainer/TabContainer/Display/VboxOptions/ResolutionOptions")
onready var _applyButton : Button = get_node("MarginContainer/VBoxContainer/MarginContainer/TabContainer/Display/VboxOptions/ApplyButton")
onready var _backButton : Button = get_node("MarginContainer/VBoxContainer/BackButtonContainer/BackButton")

# Called when the node enters the scene tree for the first time.
func _ready():
	_setup_ResolutionOptions()
	_setup_ScreenModeOptions()	
	_applyButton.connect("pressed", self, "_applyButton_pressed")
	_backButton.connect("pressed", self, "_backButton_pressed")

func _applyButton_pressed():
	_screenModeOptions_Apply()
	if(_screenModeOptions.selected == 1):
		_resolutionOptions_Apply()

func _backButton_pressed():
	self.hide()

func _setup_ResolutionOptions():
	_resolutionOptions.add_item("1920x1080")
	_resolutionOptions.add_item("1680x1050")
	_resolutionOptions.add_item("1600x900")
	_resolutionOptions.add_item("1440x900")
	_resolutionOptions.add_item("1366x768")
	_resolutionOptions.add_item("1360x768")
	_resolutionOptions.add_item("1280x1024")
	_resolutionOptions.add_item("1280x800")
	_resolutionOptions.add_item("1280x720")
	_resolutionOptions.add_item("1024x768")
	_resolutionOptions.add_item("800x600")
	_resolutionOptions.add_item("720x480")
	_resolutionOptions.add_item("640x480")
	_resolutionOptions.add_item("640x360")

func _resolutionOptions_Apply():
	var dimensions = _resolutionOptions.get_item_text(_resolutionOptions.selected).split("x")
	OS.set_window_size(Vector2(int(dimensions[0]), int(dimensions[1])))

func _setup_ScreenModeOptions():	
	_screenModeOptions.add_item("Fullscreen")
	_screenModeOptions.add_item("Windowed")
	
	_screenModeOptions.connect("item_selected", self, "_screenModeOptions_ItemSelected")
	
	if(OS.is_window_fullscreen()):
		_screenModeOptions.select(0)
	else:
		_screenModeOptions.select(1)

func _screenModeOptions_Apply():
	if(_screenModeOptions.selected == 0):
		OS.set_window_fullscreen(true)
	else:
		OS.set_window_fullscreen(false)

func _screenModeOptions_ItemSelected(selectedIndex):
	if(selectedIndex == 0):
		_resolutionOptions.disabled = true
	else:
		_resolutionOptions.disabled = false
