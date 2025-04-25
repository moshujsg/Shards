class_name CAttackComponent extends Component

@export var attack_area: Area3D
@export_flags_3d_physics var attack_area_layer : int
@export_flags_3d_physics var attack_area_mask : int
@export var own_body: NCharacter
@export var aim_component : CAim
var timer : Timer
@export var abilities : Dictionary[InputAction, RComboNode] # Just for loading RComboAbiliyy as you can't export objects
var current_step : AbilityWrapper
var _abilities : Dictionary[InputAction, AbilityWrapper] # Actual map to use, with wrapper to uniquely identify each object

func wrap_ablities() -> void:
	for action in abilities:
		_abilities[action] = AbilityWrapper.new(abilities.get(action) as RComboNode)

func _ready() -> void:
	wrap_ablities()
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
	timer.start(current_step.combo_data.combo_window)

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
	for next_attack in current_step.combo_data.next_attacks:
		if next_attack.input_action == p_action:
			return false
	return true

func get_character_animation() -> String:
	return current_step.combo_data.ability_data.animation_name

func get_next_ability(p_action: InputAction) -> AbilityWrapper:
	if not _abilities.has(p_action) and (not current_step or current_step.has_next_attack(p_action)):
		return null
	if is_new_combo(p_action):
		return _abilities.get(p_action)
	else:
		return current_step.get_next_attack(p_action)

func use_ability(p_ability: AbilityWrapper) -> void:
	timer.stop()
	current_step = p_ability
