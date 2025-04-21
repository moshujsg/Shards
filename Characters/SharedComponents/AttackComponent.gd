class_name CAttackComponent extends Component

signal ability_used(ability: RComboAbility)

@export var attack_area: Area3D
@export_flags_3d_physics var attack_area_layer : int
@export_flags_3d_physics var attack_area_mask : int
@export var own_body: NCharacter
@export var aim_component : CAim
var timer : Timer
@export var abilities : Dictionary[InputAction, RComboAbility]
var current_step : RComboAbility

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.autostart = false
	timer.timeout.connect(_on_timer_timeout)
	attack_area.body_entered.connect(cast_attack)
	#attack_area.collision_mask = attack_area_mask
	#attack_area.collision_layer = attack_area_layer

func start_timer() -> void:
	# Only open the window if there's a current follow up
	if not current_step:
		return
	#print("Combo window opened")
	timer.start(current_step.combo_window)

func _on_timer_timeout() -> void:
	#print("Combo window closed")
	current_step = null

func cast_attack(p_body: Node3D) -> void:
	if not p_body is CharacterBody3D or p_body == own_body:
		return
	var health_component : CHealth = p_body.get_node_or_null("CHealth")
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

func get_character_animation() -> String:
	return current_step.animation_name

func get_next_ability(p_action: InputAction) -> RComboAbility:
	if not abilities.has(p_action) and (not current_step or current_step.has_next_attack(p_action)):
		return null
	if is_new_combo(p_action):
		return abilities.get(p_action)
	else:
		return current_step.get_next_attack(p_action)

func use_ability(p_ability: RComboAbility) -> RAbilityEventData:
	current_step = p_ability
	timer.stop()
	current_step = p_ability
	return RAbilityEventData.new(
			p_ability.ability_data,
			own_body
			)
