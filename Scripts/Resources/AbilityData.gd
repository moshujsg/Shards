class_name RAbilityData extends Resource

enum AbilityType {
	PHYSICAL,
	AOE,
	PROJECTILE
}

@export var visual_effect_scene: PackedScene
@export var vfx_animation_name: String
@export var use_global_space: bool
#@export var impact_socket: String = "hand_r"
@export var lifetime: float = 1.0
@export var cast_range: float = 15.0
@export var type : AbilityType

func needs_target() -> bool:
	if type == AbilityType.AOE:
		return true
	return false
