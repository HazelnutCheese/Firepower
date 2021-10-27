extends Spatial

const _minLookAngleX = -45.0
const _maxLookAngleX = 0.0
const _lookSensitivity = 10.0
const _cameraReturnSensitivity = 500.0

var _nextCameraY = 0.0
var _mouseDelta = Vector2()

# Rotate the local camera on the server / each clients
func _physics_process(delta):
	_rotateCamera(_mouseDelta, delta)
	_mouseDelta = Vector2()

func _rotateCamera(mouseDelta, delta):
	# rotate the camera along the x axis
	rotation_degrees.x -= mouseDelta.y * _lookSensitivity * delta
	
	# clamp camera x rotation axis
	rotation_degrees.x = clamp(
		rotation_degrees.x, 
		_minLookAngleX, 
		_maxLookAngleX)
	
	# rotate the camera along the y-axis
	_nextCameraY -= (mouseDelta.x * 1.5) * _lookSensitivity * delta
	InputManager._updateInput("cameraY", _nextCameraY)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		_mouseDelta = event.relative
