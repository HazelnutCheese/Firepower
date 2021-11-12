class_name CaveTroll
extends VitalEntity

onready var animationTree: EnetAnimationTree = $AnimationTree

onready var behaviourTree : BehaviorTree = $BehaviorTree
onready var blackboard : Blackboard = $Blackboard
onready var skeleton : Skeleton = $Borc_cleaned/Armature/Skeleton
onready var _weaponHitbox : Area = $Borc_cleaned/Armature/Skeleton/BoneAttachment/hammer/Hitbox
onready var _weaponCollision : CollisionShape = $Borc_cleaned/Armature/Skeleton/BoneAttachment/hammer/Hitbox/CollisionShape

func _ready():
	_weaponHitbox.monitoring = false

func _hurt(agent: Node, damage: int, damageType: String) -> void:
	_playHurt()

func _impulse(agent: Node, impulse: Vector3):
	_velocity += impulse

func _playHurt():
	print("hit")
	animationTree.pset("parameters/To_OnHit/active", true)	
	_velocity = Vector3()
	_isInHitFrames = true
	yield(get_tree().create_timer(2.0), 'timeout')
	_isInHitFrames = false

func _physics_process(delta):
	apply_movement(delta)
	
	if(_isInHitFrames):
		var direction = Vector3(1,1,1).rotated(Vector3.UP, rotation.y)
		_velocity = lerp(_velocity, direction * 0, delta * 2.0)		
	else:
		rotation_degrees.x = 0
	
	var animationBlendAmount = _velocity.length() / 8.0
	animationTree.pset_unreliable(
		"parameters/Idle_To_Run/blend_amount", 
		animationBlendAmount)

func _weaponRaised():
	_weaponHitbox.monitoring = true

func _weaponLowered():
	_weaponHitbox.monitoring = false
