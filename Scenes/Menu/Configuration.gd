extends Node

onready var _configFilePath = "user://settings.cfg"
onready var _configFile = ConfigFile.new()

# Configuration Values
onready var _windowSize = "Custom"
onready var _windowSizeWidth = 1200
onready var _windowSizeHeight = 720
onready var _windowedMode = true
onready var _borderless = false
onready var _renderScale = 100

# WindowSizeOptions
onready var _windowSizeOptions = [
	"Custom",
	"1920x1080",
	"1680x1050",
	"1600x900",
	"1440x900",
	"1366x768",
	"1360x768",
	"1280x1024",
	"1280x800",
	"1280x720",
	"1024x768",
	"800x600",
	"720x480",
	"640x480"
]

func _ready():
	var err = _configFile.load(_configFilePath)
	if err != OK: # If not, something went wrong with the file loading
		pass
	
	_windowSize = _loadSetting("display", "_windowSize", _windowSize)
	_windowSizeWidth = _loadSetting("display", "_windowSizeWidth", _windowSizeWidth)
	_windowSizeHeight = _loadSetting("display", "_windowSizeHeight", _windowSizeHeight)
	_windowedMode = _loadSetting("display", "_windowedMode", _windowedMode)
	_borderless = _loadSetting("display", "_borderless", _borderless)
	_renderScale = _loadSetting("display", "_renderScale", _renderScale)

func _getWindowSizeAsId():
	for n in range(0,_windowSizeOptions.size()-1):
		if(_windowSizeOptions[n] == _windowSize):
			return n
	return 0

func _saveSetting(sectionName, settingName, settingValue):
	_configFile.set_value(sectionName, settingName, settingValue)

func _loadSetting(sectionName, settingName, fallback):
	if _configFile.has_section_key(sectionName, settingName):
		return _configFile.get_value(sectionName, settingName)
	return fallback

func _save():
	_configFile.set_value("display", "_windowSize", _windowSize)
	_configFile.set_value("display", "_windowSizeWidth", _windowSizeWidth)
	_configFile.set_value("display", "_windowSizeHeight", _windowSizeHeight)
	_configFile.set_value("display", "_windowedMode", _windowedMode)
	_configFile.set_value("display", "_borderless", _borderless)
	_configFile.set_value("display", "_renderScale", _renderScale)
	_configFile.save(_configFilePath)
