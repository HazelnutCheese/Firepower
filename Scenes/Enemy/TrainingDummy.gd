extends Spatial

onready var animationPlayer : AnimationPlayer = $StaticBody/DwardDummyRigged2/AnimationPlayer

func _ready():
	animationPlayer.play("Idle-loop")

func _hurt():
	rpc("_playAnimation", "Idle-loop")
	rpc("_playAnimation", "Land")
	rpc("_queueAnimation", "Idle-loop")

remotesync func _playAnimation(name):
	animationPlayer.play(name)

remotesync func _queueAnimation(name):
	animationPlayer.queue(name)
