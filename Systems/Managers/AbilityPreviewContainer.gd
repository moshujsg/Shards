class_name OAbilityPreviewContainer extends Object

var instance: NAbility
var ability: AbilityWrapper
var callable: Callable # used to get the position from the corresponding aim component

func _init(p_instance: NAbility, p_callable: Callable, p_ability: AbilityWrapper) -> void:
	instance = p_instance
	callable = p_callable
	ability = p_ability
