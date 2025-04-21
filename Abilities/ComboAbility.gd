# res://combo/ComboAttackNode.gd
class_name RComboAbility extends Resource

@export var input_action: InputAction
@export var animation_name: String
@export var animation : Animation
@export var next_attacks: Array[RComboAbility] = []
@export var combo_window: float = 0.6
@export var cancelable: bool = false
@export var ability_data: RAbilityData

func has_next_attack(p_action: InputAction) -> bool:
	return get_next_attack(p_action) != null

func get_next_attack(p_action: InputAction) -> RComboAbility:
	for node in next_attacks:
		if not node.input_action == p_action:
			continue
		return node
	return null

func has_follow_up() -> bool:
	return next_attacks.size() > 0 

func has_vfx() -> bool:
	if ability_data and ability_data.visual_effect_scene:
		return true
	return false
