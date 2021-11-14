class_name EnetAnimationTree
extends AnimationTree

var _animationPlayer : AnimationPlayer 

func _ready():
	_animationPlayer = get_node(anim_player)

func pset(parameterPath, args):
#	set(parameterPath, args)
	UpdateManager.qrpc(self, "_rpset", [parameterPath, args])

func pset_unreliable(parameterPath, args):
#	set(parameterPath, args)
	UpdateManager.qrpc_unreliable(self, "_rpset", [parameterPath, args])

remotesync func _rpset(animArgs):
	set(animArgs[0], animArgs[1])

func _get_currentAnim_percentage(animationPath : String) -> float:
	return get("parameters/" + animationPath + "/time")
