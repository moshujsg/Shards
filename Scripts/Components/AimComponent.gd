class_name CAim extends Node3D

@export_flags_3d_physics var raycast_collision_mask : int

@export var debug_raycast : bool
@export var camera : Camera3D
# Add these variables to your class
@export var debug_mesh: MeshInstance3D



func cast_ray(p_max_cast_distance: float) -> Dictionary:
	var space_state := get_world_3d().direct_space_state
	var origin := camera.global_transform.origin
	var direction := -camera.global_transform.basis.z
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

func _physics_process(delta: float) -> void:
	if not debug_raycast:
		return
	#debug_mesh.visible = debug_raycast
	#debug_mesh.global_position = cast_ray(15)
