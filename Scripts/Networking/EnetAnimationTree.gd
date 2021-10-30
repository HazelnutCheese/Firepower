class_name EnetAnimationTree
extends AnimationTree

func pset(parameterPath, args):
#	set(parameterPath, args)
	rpc("_rpset", parameterPath, args)

func pset_unreliable(parameterPath, args):
#	set(parameterPath, args)
	rpc_unreliable("_rpset", parameterPath, args)

remotesync func _rpset(parameterPath, args):
	set(parameterPath, args)
