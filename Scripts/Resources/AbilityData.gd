class_name RAbilityData extends Resource

enum AbilityType {
	PHYSICAL,
	AOE,
	PROJECTILE
}

@export_group("Visual Effect")
@export var visual_effect_scene: PackedScene
@export var vfx_animation_name: String
@export var use_global_space: bool

@export_group("Properties")
@export var cast_range: float = 15.0
@export var lifetime: float = 1.0
@export var type : AbilityType

@export_group("Damage")
@export var damage : int

func needs_target() -> bool:
	if type == AbilityType.AOE:
		return true
	return false
