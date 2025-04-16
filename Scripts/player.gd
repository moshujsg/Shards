class_name Player extends CharacterBody3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pivot : SpringArm3D = $Pivot
@onready var camera_3d: Camera3D = $Pivot/Camera3D
@onready var tree_root := animation_tree.tree_root as AnimationNodeStateMachine
@onready var player_controller: MainPlayerController = $PlayerController
@onready var attack_component: CAttackComponent = $Attack


func _ready() -> void:
	#player_controller.player_jumped.connect(_on_jump)
	pass

func _physics_process(delta: float) -> void:
	var speed : float = Vector2(velocity.x, velocity.z).length()
	var normalized_speed := clampf(speed / player_controller.SPEED, 0.0, 1.0)
	animation_tree["parameters/Movement/IdleRunBlend/blend_amount"] = normalized_speed
	if velocity.y != 0:
		animation_tree.set("parameters/Movement/GroundedAir/transition_request", "OnAir") 
		if velocity.y > 0:
			animation_tree.set("parameters/Movement/JumpFall/transition_request", "Jump") 
		elif velocity.y < 0:
			animation_tree.set("parameters/Movement/JumpFall/transition_request", "Fall")
	else:
		animation_tree.set("parameters/Movement/GroundedAir/transition_request", "Grounded")
	
