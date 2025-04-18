class_name CAttackComponent extends Node

signal ability_used(ability: RComboAbility)

@export var own_body: NCharacter
@export var player_controller: MainPlayerController
@export var attack_area: Area3D
@export var animation_tree: CAnimationTree
@export var aim_component : CAim
var timer : Timer
@export var abilities : Dictionary[InputAction, RComboAbility]
var current_step : RComboAbility

func _ready() -> void:
	player_controller.attack_triggered.connect(_on_attack_triggered)
	attack_area.body_entered.connect(cast_attack)
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.autostart = false
	timer.timeout.connect(_on_timer_timeout)
	animation_tree.attack_animation_finished.connect(start_timer)

func start_timer() -> void:
	# Only open the window if there's a current follow up
	if not current_step:
		return
	print("Combo window opened")
	timer.start(current_step.combo_window)

func _on_timer_timeout() -> void:
	print("Combo window closed")
	current_step = null

func cast_attack(p_body: Node3D) -> void:
	if not p_body is CharacterBody3D or p_body == own_body:
		return
	var health_component : CHealth = p_body.get_node_or_null("Health")
	if not health_component:
		return
	health_component.take_damage(10)

func is_new_combo(p_action: InputAction) -> bool:
	if not current_step:
		return true
	for next_attack in current_step.next_attacks:
		if next_attack.input_action == p_action:
			return false
	return true

func is_valid_aim_target(target: Dictionary) -> bool:
	# For now only AOE needs a cast target (ground or enemy)
	return !target.is_empty()

func _on_attack_triggered(p_action: InputAction) -> void:
	if animation_tree.is_playing():
		return

	if not abilities.has(p_action) and (not current_step or current_step.has_next_attack(p_action)):
		return
	var next_step : RComboAbility
	if is_new_combo(p_action):
		next_step = abilities.get(p_action)
	else:
		next_step = current_step.get_next_attack(p_action)

	var target_position := Vector3.ZERO
	if next_step.ability_data.needs_target():
		var target : Dictionary
		target = aim_component.cast_ray(next_step.ability_data.cast_range)
		if not is_valid_aim_target(target):
			return
		target_position = target["position"] as Vector3

	#animation_tree.play_attack_animation(current_step.animation_name)
	ability_used.emit(next_step)
	EventBus.broadcast(
		"ability_used",
		RAbilityEventData.new(
			next_step.ability_data,
			own_body,
			target_position
			)
		)

	timer.stop()
	print("Stopped timer")
	
	# Clean up the current step if it's last step
	current_step = next_step
