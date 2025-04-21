class_name NPlayer extends NCharacter

@export var animation_tree: AnimationTree 
@export var animation_player: AnimationPlayer 
@export var pivot : SpringArm3D 
@export var camera_3d: Camera3D 
@export var player_controller: MainPlayerController 
@export var attack_component: CAttackComponent 
@export var move_component : CMove
#
#func _physics_process(delta: float) -> void:
	#player_controller.update(delta)
