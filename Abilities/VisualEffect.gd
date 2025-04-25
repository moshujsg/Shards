class_name NAbility extends Node3D

enum AbilityExecutionType {
	PREVIEW,
	EXECUTE
}

@export_flags_3d_physics var effect_area_layer : int 
@export_flags_3d_physics var effect_area_mask : int
@export var preview_material : ShaderMaterial
@export var animation_player: AnimationPlayer
@export var vfx : Node3D
var ability_data: RAbilityData
var damage_area : Area3D

func load_data(p_ability_data: RAbilityData) -> void:
	ability_data = p_ability_data
	vfx = ability_data.visual_effect_scene.instantiate()
	add_child(vfx)

func run(p_execution_type: AbilityExecutionType) -> void:
	var as_preview := p_execution_type == AbilityExecutionType.PREVIEW
	damage_area.monitoring = as_preview
	animation_player.play("preview" if as_preview else "default")
	if as_preview:
		apply_preview_material()
		return
	await animation_player.animation_finished
	queue_free()

func apply_preview_material() -> void:
	var meshes := vfx.find_children('','MeshInstance3D')
	for mesh : MeshInstance3D in meshes:
		mesh.material_override = preview_material
		#for surface in mesh.get_surface_override_material_count():
			#mesh.set_surface_override_material(surface, preview_material)

func setup() -> void:
	animation_player = vfx.get_node_or_null("AnimationPlayer")
	damage_area = vfx.get_node_or_null("Area3D")
	damage_area.collision_layer = effect_area_layer
	damage_area.collision_mask = effect_area_mask
	damage_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	var character := body as NCharacter
	if not character:
		return
	var health_component : CHealth = character.get_node_or_null("CHealth")
	if not health_component:
		return
	health_component.take_damage(ability_data.damage)
