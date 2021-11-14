class_name Orc
extends VitalEntity

onready var animationTree: EnetAnimationTree = $AnimationTree

onready var behaviourTree : BehaviorTree = $BehaviorTree
onready var blackboard : Blackboard = $Blackboard
onready var skeleton : Skeleton = $Borc_cleaned/Armature/Skeleton
onready var _weaponHitbox : Area = $Borc_cleaned/Armature/Skeleton/BoneAttachment/BrutalSword/Hitbox
onready var _weaponCollision : CollisionShape = $Borc_cleaned/Armature/Skeleton/BoneAttachment/BrutalSword/Hitbox/CollisionShape
onready var _healthbar = $Healthbar

func _ready():
	_weaponHitbox.monitoring = false
	_healthbar._updateHealth(100)

func _hurt(agent: Node, damage: int, damageType: String) -> void:
	_playHurt()
	_currentHealth -= damage

func _impulse(agent: Node, impulse: Vector3):
	_velocity += impulse

func _playHurt():
	print("hit")
	animationTree.set("parameters/To_OnHit/active", true)

func _physics_process(delta):
	apply_movement(delta)
	
	var animationBlendAmount = _velocity.length() / 8.0
	animationTree.set(
		"parameters/Idle_To_Run/blend_amount", 
		animationBlendAmount)
	
	_healthbar._updateHealth(_currentHealth)

func _weaponRaised():
	_weaponHitbox.monitoring = true

func _weaponLowered():
	_weaponHitbox.monitoring = false
