class_name StateMachine
extends Node

signal transitioned(state_name)

# We export it to be able to pick the initial state in the inspector.
export var initial_state := NodePath()
onready var state: State = get_node(initial_state)

puppet var _puppet_stateName : String

func _ready() -> void:
	yield(owner, "ready")
	for child in get_children():
		child.state_machine = self
	state.enter()

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)

func _physics_process(delta: float) -> void:
	state.physics_update(delta)

remote func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	# If you reuse a state in different state machines but you don't want them 
	# all, they won't be able to transition to states that aren't in the scene tree.
	if not has_node(target_state_name):
		return
	state.exit()
	state = get_node(target_state_name)
	state.enter(msg)
	emit_signal("transitioned", state.name)
	if(get_tree().is_network_server()):
		rpc("transition_to", target_state_name, msg)
