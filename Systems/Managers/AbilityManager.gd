class_name AbilityManager extends Node3D

@export var PREFAB : PackedScene
@export_flags_3d_physics var raycast_collision_mask : int

var preview_abilities : Array[OAbilityPreviewContainer]

func _ready() -> void:
	EventBus.on("ability_used", _on_ability_used)
	EventBus.on("ability_preview", _on_ability_preview)
	EventBus.on("ability_cancelled", _on_ability_cancelled)

func _on_ability_cancelled(event_data: RAbilityEventData) -> void:
	cancel_preview(event_data.ability)

func cancel_preview(p_ability: AbilityWrapper) -> void:
	for n in range(preview_abilities.size() - 1, -1, -1):
		printt(preview_abilities[n].ability.get_instance_id(), p_ability.get_instance_id())
		if not preview_abilities[n].ability.get_instance_id() == p_ability.get_instance_id():
			continue
		var ability_preview := preview_abilities.pop_at(n) as OAbilityPreviewContainer
		ability_preview.instance.queue_free()

func _on_ability_used(event_data: RAbilityEventData) -> void:
	if not event_data.ability.combo_data:
		return
	cancel_preview(event_data.ability)
	spawn_ability(event_data, NAbility.AbilityExecutionType.EXECUTE)

func _on_ability_preview(event_data: RAbilityEventData) -> void:
	if not event_data.ability.combo_data or not event_data.target_position_callable:
		return
	var ability := spawn_ability(
		event_data,
		NAbility.AbilityExecutionType.PREVIEW
		)
	var container := OAbilityPreviewContainer.new(ability, event_data.target_position_callable, event_data.ability)
	preview_abilities.append(container)

func spawn_ability(p_event_data: RAbilityEventData, p_execution_type: NAbility.AbilityExecutionType) -> NAbility:
	if not p_event_data.ability.has_vfx():
		push_error("Tried to spawn ability but visual_effect_scene is null")
		return
	var prefab := PREFAB.instantiate() as NAbility
	prefab.load_data(p_event_data.ability.combo_data.ability_data)
	prefab.setup()
	add_child(prefab)
	prefab.run(p_execution_type)
	var target_pos := p_event_data.target_position_callable.call() as Vector3
	if target_pos == Vector3.INF:
		target_pos = Vector3.ZERO
	prefab.global_position = find_ground_from_position(target_pos)
	return prefab

func find_ground_from_position(p_position: Vector3) -> Vector3:
	var space_state := get_world_3d().direct_space_state
	var direction := Vector3.DOWN
	var max_distance := 1000.0
	var parameters := PhysicsRayQueryParameters3D.new()
 
	parameters.from = p_position + Vector3.UP * 0.1 # Adjust a bit to prevent going through ground if casted on ground
	parameters.to = p_position + direction * max_distance
	parameters.collide_with_bodies = true
	parameters.collision_mask = raycast_collision_mask
	parameters.exclude = []
	
	var result := space_state.intersect_ray(parameters)
	
	if not result:
		push_error("Tried to find ground from ability spawn location but ground was not found")
		return Vector3.INF
	return result.position

func update_preview_state(p_container: OAbilityPreviewContainer) -> void:
	var new_pos := p_container.callable.call() as Vector3
	if new_pos == Vector3.INF:
		p_container.instance.hide()
	else:
		p_container.instance.global_position = find_ground_from_position(new_pos)
		p_container.instance.show()

func _physics_process(delta: float) -> void:
	for ability in preview_abilities:
		update_preview_state(ability)
