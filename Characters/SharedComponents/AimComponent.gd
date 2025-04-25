class_name CAim extends Component

@export_flags_3d_physics var raycast_collision_mask : int

@export var base_node: Node3D
@export var enabled := true:
	set(value):
		enabled = value
		set_physics_process(value)
var target : Dictionary

func cast_ray(p_max_cast_distance: float) -> Dictionary:
	var space_state := base_node.get_world_3d().direct_space_state
	var origin := base_node.global_transform.origin
	var direction := -base_node.global_transform.basis.z
	var parameters := PhysicsRayQueryParameters3D.create(
		origin,
		origin + direction * p_max_cast_distance,
		raycast_collision_mask,
		[owner]
		)
	parameters.collide_with_bodies = true
	parameters.collide_with_areas = true
	var result := space_state.intersect_ray(parameters)

	if result:
		# Hit enemy or something valid
		return result
	return {}

func has_target() -> bool:
	return !target.is_empty()

func get_target_global_position() -> Vector3:
	if not has_target():
		return Vector3.INF
	return target["position"] as Vector3

func _physics_process(delta: float) -> void:
	target = cast_ray(1000)
	#debug_mesh.visible = debug_raycast
	#debug_mesh.global_position = cast_ray(15)
