class_name StateMachine
extends Node

signal transitioned(state_name)

# We export it to be able to pick the initial state in the inspector.
export var initial_state := NodePath()
onready var state: State = get_node(initial_state)

var stateEntered = false

puppet var _puppet_stateName : String

func _ready() -> void:
	yield(owner, "ready")
	for child in get_children():
		child._setStateMachine(self)
	state.enter()
	stateEntered = true

func _unhandled_input(event: InputEvent) -> void:
	if(stateEntered):
		state.handle_input(event)

func _physics_process(delta: float) -> void:
	if(stateEntered):
		state.physics_update(delta)

func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	# If you reuse a state in different state machines but you don't want them 
	# all, they won't be able to transition to states that aren't in the scene tree.
	if not state.get_parent().has_node(target_state_name):
		return
	var newState = state.get_parent().get_node(target_state_name)
	_transition_to_state(newState)
	emit_signal("transitioned", state.name)
	if(get_tree().is_network_server()):
		UpdateManager.qrpc(
			self, 
			"_transition_to_client", 
			[target_state_name, msg])

func transition_to_sub(target_state_name: String, msg: Dictionary = {}) -> void:
	# If you reuse a state in different state machines but you don't want them 
	# all, they won't be able to transition to states that aren't in the scene tree.
	if not state.has_node(target_state_name):
		return
	var newState = state.get_node(target_state_name)
	_transition_to_state(newState)
	emit_signal("transitioned", state.name)
	if(get_tree().is_network_server()):
		UpdateManager.qrpc(
			self, 
			"_transition_to_sub_client", 
			[target_state_name, msg])

func transition_to_any(target_state_name: String, msg: Dictionary = {}) -> void:
	# If you reuse a state in different state machines but you don't want them 
	# all, they won't be able to transition to states that aren't in the scene tree.
	var newState = _findState(self, target_state_name)
	if(newState == null):
		return
	_transition_to_state(newState)
	if(get_tree().is_network_server()):
		UpdateManager.qrpc(
			self, 
			"_transition_to_any_client", 
			[target_state_name, msg])

func _transition_to_state(newState, msg: Dictionary = {}) -> void:
	state.exit()
	stateEntered = false
	state = newState
	state.enter(msg)
	stateEntered = true
	emit_signal("transitioned", state.name)

func _findState(root, name: String):
	if root.has_node(name):
		return root.get_node(name)
	for child in root.get_children():
		var result = _findState(child, name)
		if(result != null):
			return result
	return null

remote func _transition_to_client(args):
	var target_state_name = args[0]
	var msg = args[1]
	transition_to(target_state_name, msg)

remote func _transition_to_sub_client(args):
	var target_state_name = args[0]
	var msg = args[1]
	transition_to_sub(target_state_name, msg)

remote func _transition_to_any_client(args):
	var target_state_name = args[0]
	var msg = args[1]
	transition_to_any(target_state_name, msg)
