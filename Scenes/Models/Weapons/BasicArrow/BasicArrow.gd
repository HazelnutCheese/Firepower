extends KinematicEntity

onready var _hitbox = $Cube/Hitbox

var _isActive = false
var _ricochet_count = 0
var _max_ricochet_count = 4
var _hitlist = []

func _ready():
	gravity = 15

func _physics_process(delta):
	if _isActive:
		apply_movement(delta)
		var lookAt = translation - _velocity
		if lookAt != translation:
			self.look_at(lookAt, Vector3.UP)
		
		if(is_on_wall() 
			or is_on_floor() 
			or is_on_ceiling()):
			_ricochet_count += 1
			if _ricochet_count > _max_ricochet_count:
				self.queue_free()

		var hitEntities = _hitbox.get_overlapping_bodies()
		for body in hitEntities:
			if (body is KinematicEntity
					and not _hitlist.has(body) 
					and not body.is_in_group("Friendly")):
				body._hurt(owner, 20, "piercing")
				_hitlist.append(body)

func Activate():
	_isActive = true
