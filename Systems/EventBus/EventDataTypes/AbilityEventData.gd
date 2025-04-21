class_name RAbilityEventData extends REventData

var ability_data : RAbilityData
var owner : NCharacter
var spawn_position : Vector3

func _init(p_ability_data: RAbilityData, p_owner: NCharacter) -> void:
	ability_data = p_ability_data
	owner = p_owner
