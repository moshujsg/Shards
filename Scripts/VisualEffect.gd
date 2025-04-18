class_name NVFXContainer extends Node3D

@export var animation_player: AnimationPlayer
@export var vfx : Node3D

func _ready() -> void:
	if not animation_player:
		return
	animation_player.play("default_animation")
	await animation_player.animation_finished
	queue_free()

func setup(p_vfx: PackedScene) -> void:
	vfx = p_vfx.instantiate()
	add_child(vfx)
	animation_player = vfx.get_node_or_null("AnimationPlayer")
