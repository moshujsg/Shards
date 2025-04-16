# res://combo/ComboAttackNode.gd
class_name RComboAttackNode extends Resource

@export var input_action: InputAction
@export var animation_name: String
@export var animation : Animation
@export var next_attacks: Array[RComboAttackNode] = []
@export var combo_window: float = 0.6
@export var damage: int = 10
@export var cancelable: bool = false


func has_next_attack(p_action: InputAction) -> bool:
	return get_next_attack(p_action) != null

func get_next_attack(p_action: InputAction) -> RComboAttackNode:
	for node in next_attacks:
		if not node.input_action == p_action:
			continue
		return node
	return null

func has_follow_up() -> bool:
	return next_attacks.size() > 0 
