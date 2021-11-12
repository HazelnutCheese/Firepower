extends Node

var _tickrate = 30.0
var _currentTime = 0.0
var _tickTime = 1/_tickrate

var _rset_dict = {}
var _rset_unreliable_dict = {}
var _rpc_dict = {}
var _rpc_unreliable_dict = {}

var sceneStorage = {}

func qrset(node: Node, variable: String, value):
	_rset_dict[_create_key(node, variable)] = [node, variable, value]

func qrset_unreliable(node: Node, variable: String, value):
	_rset_unreliable_dict[_create_key(node, variable)] = [node, variable, value]

func qrpc(node: Node, method: String, args):
	_rpc_dict[_create_key(node, method)] = [node, method, args]

func qrpc_unreliable(node: Node, method: String, args):
	_rpc_unreliable_dict[_create_key(node, method)] = [node, method, args]

func _create_key(node: Node, variable: String) -> String:
	return str(node) + variable

remote func _send_rset(calls: Dictionary):
	for key in calls:
		var data = calls[key]
		var nodePath = data[0]
		var node = get_node(nodePath)
		if(node == null):
			continue
		var variableName = data[1]
		var value = data[2]
		node.set(variableName, value)

remote func _send_rpc(calls: Dictionary):
	for key in calls:
		var data = calls[key]
		var nodePath = data[0]
		var node = get_node(nodePath)
		if(node == null):
			continue
		var methodName = data[1]
		var args = data[2]
		if args != null and args.size() > 0:
			node.callv(methodName, args)
		else:
			node.call(methodName)

func _physics_process(delta):
	if (get_tree().has_network_peer() and 
		get_tree().is_network_server()):
		_currentTime += delta
		if _currentTime < _tickTime:
			return
			
		_currentTime -= _tickTime
		
		var syncList = {}
		for synched in get_tree().get_nodes_in_group("Sync"):
			if is_instance_valid(synched):
				var name = synched.get_name()
				var filename = synched.get_filename() 
				var translation = null
				if(synched is Spatial):
					translation = synched.translation
				syncList[name] = [filename, translation]
		
		rpc("UpdateWorldState", syncList)
		
		for key in _rset_dict.keys():
			var rset = _rset_dict[key]
			if is_instance_valid(rset[0]):
				rset[0].rset(rset[1], rset[2])
		_rset_dict.clear()

		for key in _rset_unreliable_dict.keys():
			var rset_u = _rset_unreliable_dict[key]
			if is_instance_valid(rset_u[0]):
				rset_u[0].rset_unreliable(rset_u[1], rset_u[2])
		_rset_unreliable_dict.clear()

		for key in _rpc_dict.keys():
			var rpc = _rpc_dict[key]
			var node = rpc[0]
			var args = rpc[2]
			if is_instance_valid(node):
				if args == null or args.size() == 0:
					node.rpc_unreliable(rpc[1])
				else:
					node.rpc_unreliable(rpc[1], args)
		_rpc_dict.clear()

		for key in _rpc_unreliable_dict.keys():
			var rpc_u = _rpc_unreliable_dict[key]
			var node = rpc_u[0]
			var args = rpc_u[2]
			if is_instance_valid(node):
				if args == null or args.size() == 0:
					node.rpc_unreliable(rpc_u[1])
				else:
					node.rpc_unreliable(rpc_u[1], args)
		_rpc_unreliable_dict.clear()

remote func UpdateWorldState(entities: Dictionary):
	var level = get_tree().get_root().get_node("Control/GameViewportContainer/Viewport/testScene")
	
	var keptNodes = []
	for synched in get_tree().get_nodes_in_group("Sync"):
		var name = synched.get_name()
		if not entities.has(name):
			synched.queue_free()
		else:
			keptNodes.append(name)
	
	for key in entities:
		if not keptNodes.has(key):
			var filename = entities[key][0]
			var newNode = null
			if not sceneStorage.has(filename):
				sceneStorage[filename] = load(filename)
			newNode = sceneStorage[filename].instance()
			newNode.set_name(key)
			if(newNode is Spatial):
				newNode.translation = entities[key][1]
			level.add_child(newNode)
	
