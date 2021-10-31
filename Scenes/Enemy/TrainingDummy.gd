class_name TrainingDummy
extends VitalEntity

onready var animationTree: EnetAnimationTree = $AnimationTree

onready var behaviourTree : BehaviorTree = $BehaviorTree
onready var blackboard : Blackboard = $Blackboard
onready var skeleton : Skeleton = $DwardDummyRigged2/Armature/Skeleton

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
