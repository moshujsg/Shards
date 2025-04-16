#class_name CAnimationManager extends Node
#
#@export var animation_tree : AnimationTree
#@export var animation_player : AnimationPlayer
#
#func get_node(p_node_path: String) -> void:
	#if animation_tree["parameters/AttackAdd/active"]:
		#return
	#animation_tree["parameters/AttackAdd/request"] = AnimationNodeOneShot.OneShotRequest.ONE_SHOT_REQUEST_FIRE
	#(tree_root.get_node("Attack") as AnimationNodeAnimation).animation = get_attack_animation()
	#
