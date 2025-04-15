class_name AttackManager extends Node3D

@onready var player_controller: MainPlayerController = $"../PlayerController"
@onready var animation_tree: AnimationTree = $"../AnimationTree"
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

func _ready() -> void:
	player_controller.attack_triggered.connect(_on_attack_triggered)

func _on_attack_triggered() -> void:
	animation_tree["parameters/AttackAdd/request"] = AnimationNodeOneShot.OneShotRequest.ONE_SHOT_REQUEST_FIRE
