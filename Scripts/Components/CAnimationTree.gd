class_name CAnimationTree extends AnimationTree

signal attack_animation_finished

@export var attack_component : CAttackComponent
var playback : AnimationNodeStateMachinePlayback = get("parameters/StateMachine/playback")
var attack_node : AnimationNodeAnimation 
var is_playing_animation : bool
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

func _ready() -> void:
	attack_node = ((tree_root as AnimationNodeBlendTree).get_node("Attack") as AnimationNodeAnimation)
	attack_component.ability_used.connect(_on_ability_used)

func _on_ability_used(ability: RComboAbility) -> void:
	play_attack_animation(ability.animation_name)

func is_playing() -> bool:
	return is_playing_animation

func play_attack_animation(p_animation_name: String) -> void:
	if not animation_player.has_animation(p_animation_name):
		push_error("Attack animation not found")
	print("Received animation request " + p_animation_name)
	attack_node.animation = p_animation_name
	set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	is_playing_animation = true

func _physics_process(delta: float) -> void:
	var node_playing := get("parameters/AttackOneShot/active") as bool
	if is_playing_animation and not node_playing:
		attack_animation_finished.emit()
		is_playing_animation = false
