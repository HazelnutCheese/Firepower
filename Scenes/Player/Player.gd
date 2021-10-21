extends KinematicBody

# Load the custom images for the mouse cursor.
var arrow = load("res://UI/Cursor.png")

# inGameMenu
onready var _inGameMenu : Popup = get_node("CanvasLayer/InGameMenu")

# cam look
const _minLookAngleX = -45.0
const _maxLookAngleX = 0.0
const _lookSensitivity = 30.0
const _cameraReturnSensitivity = 500.0
onready var _cameraSpatial : Spatial = get_node("Camera_Spatial")
var _mouseDelta : Vector2 = Vector2()

# movement
const _moveSpeed = 10
const _gravity = 28
const _jumpSpeed = 14
var _velocity : Vector3 = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_custom_mouse_cursor(arrow)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_mouseDownLeft"):	
		rotatePlayer(delta)	
	elif Input.is_action_pressed("ui_mouseDownRight"):	
		rotateCamera(delta)	
	elif _cameraSpatial.rotation_degrees.y != 0:
		resetCameraBehind(delta)

	# reset the mouseDelta vector
	_mouseDelta = Vector2()
	
	var input = Vector3()
	if Input.is_action_pressed("ui_up") or (
		Input.is_action_pressed("ui_mouseDownLeft") and 
		Input.is_action_pressed("ui_mouseDownRight")):
		input.z -= 1
		
	if Input.is_action_pressed("ui_down"):
		input.z += 1
	
	if Input.is_action_pressed("ui_right"):
		input.x += 1
		
	if Input.is_action_pressed("ui_left"):
		input.x -= 1
	
	input = input.rotated(Vector3.UP, rotation.y)	
	input = input.normalized() * _moveSpeed
	
	if is_on_floor():
		_velocity.x = input.x
		_velocity.z = input.z
	
	if Input.is_action_pressed("ingame_jump") and is_on_floor():
		_velocity.y = _jumpSpeed
	
	_velocity.y -= delta * _gravity	
	_velocity = move_and_slide(_velocity, Vector3.UP)

func _input(event):
	if event is InputEventMouseMotion:
		_mouseDelta = event.relative

func rotatePlayer(delta):
	# rotate the player along the y axis
	_cameraSpatial.rotation_degrees.x -= _mouseDelta.y * _lookSensitivity * delta
  
	# clamp camera x rotation axis
	_cameraSpatial.rotation_degrees.x = clamp(
		_cameraSpatial.rotation_degrees.x, 
		_minLookAngleX, 
		_maxLookAngleX)
  
	# rotate the player along their y-axis
	var cameraRotationY = _cameraSpatial.rotation_degrees.y
	_cameraSpatial.rotation_degrees.y = 0
	rotation_degrees.y += cameraRotationY
	rotation_degrees.y -= (_mouseDelta.x * 1.5) * _lookSensitivity * delta

func rotateCamera(delta):
	# rotate the camera along the y axis
	_cameraSpatial.rotation_degrees.x -= _mouseDelta.y * _lookSensitivity * delta
  
	# clamp camera x rotation axis
	_cameraSpatial.rotation_degrees.x = clamp(
		_cameraSpatial.rotation_degrees.x, 
		_minLookAngleX, 
		_maxLookAngleX)
  
	# rotate the camera along their y-axis
	_cameraSpatial.rotation_degrees.y -= _mouseDelta.x * _lookSensitivity * delta
	fmodYRotation(_cameraSpatial)

func resetCameraBehind(delta):
	var returnDelta = delta * _cameraReturnSensitivity
	
	_cameraSpatial.rotation_degrees.y = clamp(
		_cameraSpatial.rotation_degrees.y, 
		-(_cameraSpatial.rotation_degrees.abs().y) + returnDelta, 
		_cameraSpatial.rotation_degrees.abs().y - returnDelta)
		
	if (_cameraSpatial.rotation_degrees.y < returnDelta and 
		_cameraSpatial.rotation_degrees.y > 0) or (
		_cameraSpatial.rotation_degrees.y > -returnDelta and 
		_cameraSpatial.rotation_degrees.y < 0):
		_cameraSpatial.rotation_degrees.y = 0

func fmodYRotation(spatial):
	spatial.rotation_degrees.y = fmod(spatial.rotation_degrees.y, 360.0)
	spatial.rotation_degrees.y = fmod(spatial.rotation_degrees.y, -360.0)
