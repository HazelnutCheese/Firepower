class_name KinematicEntity
extends KinematicBody

# Movement
var gravity = 32.0
var _velocity : Vector3 = Vector3()

# networking
puppet var puppet_translation = Vector3()
puppet var puppet_rotation_degrees = Vector3()
puppet var puppet_velocity = Vector3()

var replicate_rotation = true

func apply_movement(delta):
	_velocity.y -= delta * gravity
	_velocity = move_and_slide(_velocity, Vector3.UP, true)
	if(get_tree().is_network_server()):
		if(puppet_translation != translation):
			puppet_translation = translation
			UpdateManager.qrset_unreliable(
				self, 
				"puppet_translation", 
				translation)
	
		if(puppet_rotation_degrees != rotation_degrees):
			puppet_rotation_degrees = rotation_degrees
			UpdateManager.qrset_unreliable(
				self, 
				"puppet_rotation_degrees", 
				rotation_degrees)
		if(puppet_velocity != _velocity):
			puppet_velocity = _velocity
			UpdateManager.qrset_unreliable(
				self, 
				"puppet_velocity", 
				_velocity)
			
#		rset_unreliable("puppet_translation", translation)
#		rset_unreliable("puppet_rotation_degrees", rotation_degrees)
#		rset_unreliable("puppet_velocity", _velocity)
	else:
		translation = lerp(translation, puppet_translation, 0.5)
		if replicate_rotation:
			rotation_degrees = lerp(rotation_degrees, puppet_rotation_degrees, 0.8)
		_velocity = lerp(_velocity, puppet_velocity, 0.5)
