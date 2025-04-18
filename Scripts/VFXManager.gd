class_name AbilityManager extends Node3D

const PREFAB : PackedScene = preload("res://Prefabs/VFXScene.tscn")
@export_flags_3d_physics var raycast_collision_mask : int

func _ready() -> void:
	EventBus.on("ability_used", _on_ability_used)

func _on_ability_used(event_data: RAbilityEventData) -> void:
	if not event_data.ability_data:
		return
	spawn_ability(event_data)

func spawn_ability(event_data: RAbilityEventData) -> void:
	if not event_data.ability_data.visual_effect_scene:
		return
	var prefab := PREFAB.instantiate() as NVFXContainer
	prefab.setup(event_data.ability_data.visual_effect_scene)
	#prefab.top_level = ability_data.use_global_space
	add_child(prefab)
	prefab.global_position = find_ground_from_position(event_data.spawn_position)
	

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
