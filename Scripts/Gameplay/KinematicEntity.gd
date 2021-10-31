class_name KinematicEntity
extends KinematicBody

# Movement
const GRAVITY = 32.0
var _velocity : Vector3 = Vector3()

# networking
puppet var puppet_translation = Vector3()
puppet var puppet_rotation_degrees = Vector3()
puppet var puppet_velocity = Vector3()

func apply_movement(delta):
	if(get_tree().is_network_server()):
		_velocity.y -= delta * GRAVITY
		_velocity = move_and_slide(_velocity, Vector3.UP, true)

		rset_unreliable("puppet_translation", translation)
		rset_unreliable("puppet_rotation_degrees", rotation_degrees)
		rset_unreliable("puppet_velocity", _velocity)
	else:
		translation = puppet_translation
		rotation_degrees = puppet_rotation_degrees
		_velocity = puppet_velocity
