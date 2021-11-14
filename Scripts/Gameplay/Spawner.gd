extends Spatial
class_name Spawner

export(float) var spawn_time_ms: float = 10000.0
export(float) var initial_delay_ms: float = 0.0
export(int) var total_limit: int = 10.0
export(String, FILE, "*.tscn,*.scn") var spawn_type_path: String

var _wait_for_delay = false
var _scene_to_spawn = null
var _current_time_ms = 0.0

var spawned = []

func _ready():
	_scene_to_spawn = load(spawn_type_path)
	if(not get_tree().is_network_server()):
		return
	if(initial_delay_ms > 0.0):
		_wait_for_delay = true
		yield(get_tree().create_timer(initial_delay_ms / 1000), 'timeout')
		_wait_for_delay = false

func _physics_process(delta):
	if(not get_tree().is_network_server()):
		return
	
	if(_wait_for_delay):
		return
	
	if(total_limit > 0 and spawned.size() >= total_limit):
		return
	_current_time_ms += (delta * 1000)
	if(_current_time_ms > spawn_time_ms):
		_current_time_ms = _current_time_ms - spawn_time_ms
		_spawn()

func _spawn():
	var node = _scene_to_spawn.instance()
	node.set_name(str(node)+str(spawned.size()))
	node.translation = self.translation
	node.rotation = self.rotation
	spawned.append(node)
	get_parent().add_child(node)

