class_name PlayerCamera
extends Spatial

var Min_LookAngle_X = -45.0
var Max_LookAngle_X = 0.0
const _lookSensitivity = 10.0
const _cameraReturnSensitivity = 500.0

var _nextCameraY = 0.0
var _mouseDelta = Vector2()

onready var SpineIK_Target : Position3D = $SpineIK_Target

# Rotate the local camera on the server / each clients
func _physics_process(delta):
	_rotateCamera(_mouseDelta, delta)
	_mouseDelta = Vector2()

func _rotateCamera(mouseDelta, delta):
	# rotate the camera along the x axis
	rotation_degrees.x += mouseDelta.y * _lookSensitivity * delta
#	SpineIK_Target.rotation_degrees.x += mouseDelta.y * _lookSensitivity * delta
	
	# clamp camera x rotation axis
	rotation_degrees.x = clamp(
		rotation_degrees.x, 
		Min_LookAngle_X, 
		Max_LookAngle_X)
	
	# rotate the camera along the y-axis
	var change = (mouseDelta.x * 1.5) * _lookSensitivity * delta
	_nextCameraY -= change
	InputManager._updateInput("cameraY", _nextCameraY)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		_mouseDelta = event.relative
