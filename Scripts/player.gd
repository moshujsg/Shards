class_name NPlayer extends NCharacter

@export var animation_tree: AnimationTree 
@export var animation_player: AnimationPlayer 
@export var pivot : SpringArm3D 
@export var camera_3d: Camera3D 
@export var player_controller: MainPlayerController 
@export var attack_component: CAttackComponent 


func _ready() -> void:
	#player_controller.player_jumped.connect(_on_jump)
	pass


func _physics_process(delta: float) -> void:
	var speed : float = Vector2(velocity.x, velocity.z).length()
	var normalized_speed := clampf(speed / player_controller.SPEED, 0.0, 1.0)
	animation_tree["parameters/Movement/IdleRunBlend/blend_amount"] = normalized_speed
	var forward_velocity :=  velocity.dot(transform.basis.z) / player_controller.SPEED
	animation_tree.set("parameters/Movement/RunAnim/blend_amount", forward_velocity)
	if velocity.y != 0:
		animation_tree.set("parameters/Movement/GroundedAir/transition_request", "OnAir") 
		if velocity.y > 0:
			animation_tree.set("parameters/Movement/JumpFall/transition_request", "Jump") 
		elif velocity.y < 0:
			animation_tree.set("parameters/Movement/JumpFall/transition_request", "Fall")
	else:
		animation_tree.set("parameters/Movement/GroundedAir/transition_request", "Grounded")
	
