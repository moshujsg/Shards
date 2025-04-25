class_name RAbilityEventData extends REventData

var ability : AbilityWrapper
var owner : NCharacter
var target_position_callable : Callable

func _init(p_ability: AbilityWrapper, p_owner: NCharacter, p_target_position_callable: Callable) -> void:
	ability = p_ability
	owner = p_owner
	target_position_callable = p_target_position_callable
