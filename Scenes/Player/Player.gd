extends KinematicBody

# Camera
var playerCameraScene = load("res://Scenes/Player/PlayerCamera.tscn")
var localCamera = null

# movement
const _moveSpeed = 10
const _gravity = 32
const _jumpSpeed = 32
var _velocity : Vector3 = Vector3()
var _isWalking = false
var _isFalling = false
var _isJumping = false

# networking
var _networkId = -1
puppet var puppet_translation = Vector3()
puppet var puppet_rotation_degrees = Vector3()
puppet var puppet_camera_rotation_degrees = Vector3()
puppet var puppet_velocity = Vector3()
puppet var puppet_isWalking = false
puppet var puppet_isFalling = false
puppet var puppet_isJumping = false
remote var puppet_forServer_cameraY = 0.0

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if(get_tree().is_network_server()):		
		_velocity = move_and_slide(_velocity, Vector3.UP)
		
		var networkInputs = InputManager._getInputs(_networkId)

		var input = Vector3()
		if(networkInputs["inGame_MoveForward"]):
			input.z -= 1
		if(networkInputs["inGame_MoveBackward"]):
			input.z += 1
		if(networkInputs["inGame_StrafeLeft"]):
			input.x -= 1
		if(networkInputs["inGame_StrafeRight"]):
			input.x += 1
		
		_isWalking = not (input.x == 0 and input.z == 0)
		input = input.rotated(Vector3.UP, rotation.y)	
		input = input.normalized() * _moveSpeed

		_velocity.y -= delta * _gravity
		if is_on_floor():
			if(_isFalling):
				_isFalling = false
				_isJumping = false
			_velocity.x = input.x
			_velocity.z = input.z
			if(networkInputs["inGame_Jump"]):
				_velocity.y = _jumpSpeed
				_isJumping = true
		else:
			_isFalling = true

		if(_isFalling and _velocity.y < 0):
			_isJumping = false
		
		rset_unreliable("puppet_translation", translation)
		rset_unreliable("puppet_velocity", _velocity)
		rset_unreliable("puppet_rotation_degrees", rotation_degrees)
		rset_unreliable("puppet_isWalking", _isWalking)
		rset_unreliable("puppet_isFalling", _isFalling)
		rset_unreliable("puppet_isJumping", _isJumping)
		
		if(localCamera != null):
			rotation_degrees.y = localCamera._nextCameraY
		else:
			rotation_degrees.y = networkInputs["cameraY"]
	else:	
		translation = puppet_translation
		_velocity = puppet_velocity
		rotation_degrees = puppet_rotation_degrees
		_isWalking = puppet_isWalking
		_isFalling = puppet_isFalling
		_isJumping = puppet_isJumping
		
		_velocity.y -= delta * _gravity
		_velocity = move_and_slide(_velocity, Vector3.UP)
		
		if(localCamera != null):
			rotation_degrees.y = localCamera._nextCameraY
	
	if is_on_floor():
		if(_isJumping):
			_animationPlayer.play("Jump", -1, 2)
		elif(_isFalling):
			# give up on this for now
			_animationPlayer.play("Land")
		elif(_isWalking):
			_animationPlayer.play("Run")
		else:
			_animationPlayer.play("Idle")
	else:
		_animationPlayer.queue("Falling")
