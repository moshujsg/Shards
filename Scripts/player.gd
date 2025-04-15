class_name Player extends CharacterBody3D

enum MovementState {
	RUN,
	IDLE,
	JUMP
}

@export_group("Movement States")
@export var movement_states : Dictionary[MovementState, RMovementState]

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pivot : SpringArm3D = $Pivot
@onready var camera_3d: Camera3D = $Pivot/Camera3D
@onready var tree_root := animation_tree.tree_root as AnimationNodeStateMachine
@onready var player_controller: MainPlayerController = $PlayerController

var movement_state : MovementState:
	set(value):
		if value == movement_state:
			return
		movement_state = value
		#load_movestate()

func _ready() -> void:
	player_controller.player_jumped.connect(_on_jump)

func _on_jump() -> void:
	#animation_tree["parameters/JumpOS/request"] = AnimationNodeOneShot.OneShotRequest.ONE_SHOT_REQUEST_FIRE
	pass
func _physics_process(delta: float) -> void:
	#bs_node.set_parameter("blend_amount",lerpf(0, )) 
	var speed : float = Vector2(velocity.x, velocity.z).length()
	var normalized_speed := clampf(speed / player_controller.SPEED, 0.0, 1.0)
	animation_tree["parameters/Movement/IdleRunBlend/blend_amount"] = normalized_speed
	if velocity.y != 0:
		animation_tree["parameters/Movement/GroundedAir/transition_request"] = "OnAir"
		if velocity.y > 0:
			animation_tree["parameters/Movement/JumpFall/transition_request"] = "Jump"
		elif velocity.y < 0:
			animation_tree["parameters/Movement/JumpFall/transition_request"] = "Fall"
	else:
		animation_tree["parameters/Movement/GroundedAir/transition_request"] = "Grounded"
	
