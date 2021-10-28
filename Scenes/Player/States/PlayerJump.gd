extends PlayerBaseState

const JUMP_VELOCITY = 32

func _ready():
	yield(owner, "ready")
	player._animationPlayer.set_blend_time("Jump", "Falling", 0.25)

func physics_update(_delta: float) -> void:
	if(get_tree().is_network_server()):
		if(player._velocity.y < 0):
			state_machine.transition_to("Fall")

func enter(_msg := {}) -> void:
	player._velocity.y = JUMP_VELOCITY
	player._animationPlayer.play("Jump")
