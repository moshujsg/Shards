class_name NAbility extends Node3D

@export_flags_3d_physics var effect_area_layer : int 
@export_flags_3d_physics var effect_area_mask : int
@export var animation_player: AnimationPlayer
@export var vfx : Node3D
var ability_data: RAbilityData
var damage_area : Area3D

func _ready() -> void:
	if not animation_player:
		return
	animation_player.play("default_animation")
	await animation_player.animation_finished
	queue_free()

func setup(p_ability_data: RAbilityData) -> void:
	ability_data = p_ability_data
	vfx = ability_data.visual_effect_scene.instantiate()
	add_child(vfx)
	animation_player = vfx.get_node_or_null("AnimationPlayer")
	damage_area = vfx.get_node_or_null("Area3D")
	damage_area.collision_layer = effect_area_layer
	damage_area.collision_mask = effect_area_mask
	damage_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	var character := body as NCharacter
	if not character:
		return
	var health_component : CHealth = character.get_node_or_null("Health")
	if not health_component:
		return
	health_component.take_damage(ability_data.damage)
