class_name Player
extends KinematicBody

# Camera
var playerCameraScene = load("res://Scenes/Player/PlayerCamera.tscn")
var localCamera = null

# HUD
var remoteHudScene = load("res://Scenes/Player/RemoteHud.tscn")
var localHud = null
var remoteHud = null

# Gameplay
const MAX_HEALTH = 100
var _currentHealth = 100

# movement
const _gravity = 32
var _velocity : Vector3 = Vector3()

# networking
var _networkId = -1
puppet var puppet_translation = Vector3()
puppet var puppet_rotation_degrees = Vector3()
puppet var puppet_camera_rotation_degrees = Vector3()
puppet var puppet_velocity = Vector3()
remote var puppet_forServer_cameraY = 0.0
remote var puppet_current_health = 100

# Animation
onready var _animationPlayer : AnimationPlayer = get_node("DwardDummyRigged2/AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	_animationPlayer.set_blend_time("Idle", "Run", 0.25)
	_animationPlayer.set_blend_time("Run", "Idle", 0.25)
	_animationPlayer.set_blend_time("Run", "Jump", 0.25)
	_animationPlayer.set_blend_time("Jump", "Falling", 0.25)
	_animationPlayer.set_blend_time("Falling", "Land", 0.25)
	_animationPlayer.set_blend_time("Land", "Idle", 1.5)
	_animationPlayer.set_blend_time("Land", "Run", 1.0)

func _setup(networkId):
	_networkId = networkId
	if(_networkId == ServerClient._networkId):
		localCamera = playerCameraScene.instance()
		self.add_child(localCamera)
		localHud = get_tree().get_root().get_node("Control/HUD")
	else:
		remoteHud = remoteHudScene.instance()
		self.add_child(remoteHud)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if(get_tree().is_network_server()):
		_velocity.y -= delta * _gravity
		_velocity = move_and_slide(_velocity, Vector3.UP)
		
		rset_unreliable("puppet_translation", translation)
		rset_unreliable("puppet_velocity", _velocity)
		rset_unreliable("puppet_rotation_degrees", rotation_degrees)
		rset_unreliable("puppet_current_health", _currentHealth)
		
		if(_networkId != 1):
			var networkInputs = InputManager._getInputs(_networkId)
			rotation_degrees.y = networkInputs["cameraY"]
	else:	
		translation = puppet_translation
		_velocity = puppet_velocity
		rotation_degrees = puppet_rotation_degrees
		_currentHealth = puppet_current_health
		
		_velocity.y -= delta * _gravity
		_velocity = move_and_slide(_velocity, Vector3.UP)
		
	if(localCamera != null):
		rotation_degrees.y = localCamera._nextCameraY

	if(localHud != null):
		localHud._updateHealth(_currentHealth)
	else:
		remoteHud._updateHealth(_currentHealth)
