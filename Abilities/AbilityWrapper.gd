class_name AbilityWrapper extends Object

var combo_data : RComboNode
var _next_combos : Array[AbilityWrapper]
func _init(p_combo_data: RComboNode) -> void:
	combo_data = p_combo_data
	wrap_next_attacks()

func has_next_attack(p_action: InputAction) -> bool:
	return get_next_attack(p_action) != null

func wrap_next_attacks() -> void:
	for attack in combo_data.next_attacks:
		_next_combos.append(AbilityWrapper.new(attack))

func get_next_attack(p_action: InputAction) -> AbilityWrapper:
	for node in _next_combos:
		if not node.combo_data.input_action == p_action:
			continue
		return node
	return null


func has_follow_up() -> bool:
	return _next_combos.size() > 0 

func has_vfx() -> bool:
	if combo_data.ability_data and combo_data.ability_data.visual_effect_scene:
		return true
	return false
