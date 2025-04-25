class_name RAbilityData extends Resource

enum AbilityType {
	PHYSICAL,
	AOE,
	PROJECTILE
}

@export_group("Visuals")
@export var visual_effect_scene: PackedScene
@export var vfx_animation_name: String
@export var use_global_space: bool
@export var animation_name: String
@export var animation : Animation

@export_group("Properties")
@export var cast_range: float = 15.0:
	set(value):
		cast_range = value
		cast_range_squared = pow(value,2)
@export var lifetime: float = 1.0
@export var type : AbilityType

@export_group("Damage")
@export var damage : int

var cast_range_squared : float

func is_target_in_range(p_position: Vector3, p_target_position: Vector3) -> bool:
	return p_position.distance_squared_to(p_target_position) <= cast_range_squared

func needs_target() -> bool:
	if type == AbilityType.AOE:
		return true
	return false
