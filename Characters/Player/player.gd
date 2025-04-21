class_name NPlayer extends NCharacter

@export var animation_tree: AnimationTree 
@export var animation_player: AnimationPlayer 
@export var pivot : SpringArm3D 
@export var camera_3d: Camera3D 
@export var player_controller: MainPlayerController 
@export var attack_component: CAttackComponent 
@export var move_component : CMove

func _ready() -> void:
	#player_controller.player_jumped.connect(_on_jump)
	pass

func _physics_process(delta: float) -> void:
	player_controller.update(delta)
	move_component.update(delta, player_controller.move_input)
	animation_tree.set("parameters/Movement/RunAnim/blend_amount", move_component.forward_velocity)
	animation_tree.set("parameters/Movement/IdleRunBlend/blend_amount", move_component.normalized_speed)
	animation_tree.set("parameters/Movement/GroundedAir/transition_request", move_component.get_state_as_string()) 
