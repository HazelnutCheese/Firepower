extends PlayerBaseState

var animationHasEnded = false
var localCamera = null

const ATTACK_FORWARD_VELOCITY = 0.25

var comboFrame = 0
var puppet_comboFrame = 0

var weaponHitbox = null
var weaponCollision = null
var hitList = []

func _ready():
	yield(owner, "ready")
	localCamera = player.localCamera
	weaponHitbox = player._weaponHitbox
	weaponCollision = player._weaponCollision

func physics_update(_delta: float) -> void:
	if(get_tree().is_network_server()):
		var networkInputs = InputManager._getInputs(player._networkId)

		var input = Vector3()
		if(networkInputs["inGame_MoveForward"]):
			input.z -= 1
		if(networkInputs["inGame_MoveBackward"]):
			input.z += 1
		if(networkInputs["inGame_StrafeLeft"]):
			input.x -= 1
		if(networkInputs["inGame_StrafeRight"]):
			input.x += 1
		
		var isWalking = not (input.x == 0 and input.z == 0)
		
		if(player._animationTree.get("parameters/To_MeleeAttack1/active")):
			var overlappingBodies = weaponHitbox.get_overlapping_bodies()
			for body in overlappingBodies:
				_weaponHitbox_entered1(body)
			if(comboFrame == 0 and networkInputs["inGame_Attack1"]):
				comboFrame = 1
			return
		if(player._animationTree.get("parameters/To_MeleeAttack2/active")):
			var overlappingBodies = weaponHitbox.get_overlapping_bodies()
			for body in overlappingBodies:
				_weaponHitbox_entered2(body)
			return

		if(comboFrame == 1):
			comboFrame = 2
			_doMeleeAttack2()
		elif(networkInputs["inGame_Jump"]):
			state_machine.transition_to("Jump")
		elif(isWalking):
			state_machine.transition_to("Walk")
		else:
			state_machine.transition_to("Idle")

func _doMeleeAttack1():
	if(get_tree().is_network_server()):
		player._animationTree.pset("parameters/To_MeleeAttack1/active", true)
		hitList.clear()
		player._velocity = Vector3()
		InputManager._updateRemoteInput(player._networkId,"inGame_Attack1", false)
		var momentum = Vector3(0,0,-1).rotated(Vector3.UP, player.rotation.y)
		momentum = momentum.normalized() * ATTACK_FORWARD_VELOCITY
		player._velocity.x = momentum.x
		player._velocity.z = momentum.z

remote func _doMeleeAttack2():
	if(get_tree().is_network_server()):
		player._animationTree.pset("parameters/To_MeleeAttack2/active", true)
		hitList.clear()
		player._velocity = Vector3()
		InputManager._updateRemoteInput(player._networkId,"inGame_Attack1", false)
		var momentum = Vector3(0,0,-1).rotated(Vector3.UP, player.rotation.y)
		momentum = momentum.normalized() * ATTACK_FORWARD_VELOCITY
		player._velocity.x = momentum.x
		player._velocity.z = momentum.z

func _weaponHitbox_entered1(body):
	if(body != null):
		var name = body.get_name()
		if((not hitList.has(name)) and body.has_method("_hurt")):
			body._hurt(player, 0, "slashing")
			var impulseDirection = player.translation.direction_to(body.translation)
			impulseDirection.y = 1
			var impulse = impulseDirection * Vector3(0.5,12,0.5)
			body._impulse(player, impulse)
			hitList.append(name)

func _weaponHitbox_entered2(body):
	if(body != null):
		var name = body.get_name()
		if((not hitList.has(name)) and body.has_method("_hurt")):
			body._hurt(player, 0, "slashing")
			var impulseDirection = player.translation.direction_to(body.translation)
			impulseDirection.y = 1
			var impulse = impulseDirection * Vector3(20,15,20)
			body._impulse(player, impulse)
			hitList.append(name)

func enter(_msg := {}) -> void:
	if(get_tree().is_network_server()):
		weaponCollision.disabled = false
		_doMeleeAttack1()
		comboFrame = 0
	player._rotateWithPlayer = false
	

func exit(_msg := {}) -> void:
	if(get_tree().is_network_server()):
		weaponCollision.disabled = true
	player._rotateWithPlayer = true
