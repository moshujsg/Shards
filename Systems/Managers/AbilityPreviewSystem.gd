#class_name AbilityPreviewSystem extends AbilityManager
#
#var previewed_abilities : Array[RAbilityPreviewEventData]
#
#func _ready() -> void:
	#EventBus.on("ability_preview", handle_ability_preview)
#
#func handle_ability_preview(p_ability_preview_data: RAbilityPreviewEventData) -> void:
	#previewed_abilities.append(p_ability_preview_data)
#
##func update_position(p_ability: RAbilityPreviewEventData) -> void:
	##p_ability.
#
#func _physics_process(delta: float) -> void:
	#for ability in previewed_abilities:
		#update_position()
