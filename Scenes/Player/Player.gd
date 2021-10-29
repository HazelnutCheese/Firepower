class_name Player
extends KinematicBody

# Animation
onready var _animationTree : AnimationTree = $AnimationTree

# Camera
var localCamera = null
var _rotateWithPlayer = true

# HUD
var remoteHudScene = load("res://Scenes/Player/RemoteHud.tscn")
var localHud = null
var remoteHud = null

# Gameplay
const MAX_HEALTH = 100
var _currentHealth = 100
onready var _weaponHitbox = $Hitbox
onready var _weaponCollision = $Hitbox/WeaponCollision

# movement
const GRAVITY = 32.0
const MAX_MOVE_VELOCITY = 8.0
const MAX_AIR_MOVE_VELOCITY = 20
const MAX_SPRINT_VELOCITY = 16.0
const AIR_ACCEL = 0.4
const ANGULAR_ACCEL = 15
var _velocity : Vector3 = Vector3()
var _canRotate = true
onready var playerModel = $PlayerModel

# networking
var _networkId = -1
puppet var puppet_translation = Vector3()
puppet var puppet_rotation_degrees = Vector3()
puppet var puppet_camera_rotation_degrees = Vector3()
puppet var puppet_velocity = Vector3()
remote var puppet_forServer_cameraY = 0.0
remote var puppet_current_health = 100

func _setup(networkId):
	_networkId = networkId
	if(_networkId == ServerClient._networkId):
		localCamera = get_tree().get_root().get_node("Control")._localCamera
		localHud = get_tree().get_root().get_node("Control/HUD")
	else:
		remoteHud = remoteHudScene.instance()
		self.add_child(remoteHud)

func _physics_process(delta):
	if(get_tree().is_network_server()):
		_velocity.y -= delta * GRAVITY
		_velocity = move_and_slide(_velocity, Vector3.UP)
		
		if(_networkId != 1 and _rotateWithPlayer):
			var networkInputs = InputManager._getInputs(_networkId)
			var direction = Vector3(1,1,1).rotated(Vector3.UP, deg2rad(networkInputs["cameraY"]))
			rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), ANGULAR_ACCEL * delta)
		
		rset_unreliable("puppet_translation", translation)
		rset_unreliable("puppet_velocity", _velocity)
		rset_unreliable("puppet_rotation_degrees", rotation_degrees)
		rset_unreliable("puppet_current_health", _currentHealth)
	else:
		translation = puppet_translation
		_velocity = puppet_velocity
		rotation_degrees = puppet_rotation_degrees
		_currentHealth = puppet_current_health
		_velocity.y -= delta * GRAVITY
		_velocity = move_and_slide(_velocity, Vector3.UP)
		
	if(localCamera != null):
		localCamera.translation = translation
		localCamera.rotation_degrees.y = localCamera._nextCameraY
		if(_rotateWithPlayer):
			var direction = Vector3(1,1,1).rotated(Vector3.UP, localCamera.rotation.y)
			rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), ANGULAR_ACCEL * delta)
			
	if(localHud != null):
		localHud._updateHealth(_currentHealth)
	else:
		remoteHud._updateHealth(_currentHealth)
