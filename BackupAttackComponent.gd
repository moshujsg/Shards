#class_name CAttackComponent extends Node
#
#enum ComboState {
	#NONE,
	#PLAYING_ANIMATION,
	#AWAITING_COMBO,
#}
#
#@export var own_body: CharacterBody3D
#@export var player_controller: MainPlayerController
#@export var animation_player: AnimationPlayer
#@export var attack_area: Area3D
#@export var animation_tree: AnimationTree
#@onready var attack: CAttackComponent = $"."
#
#@export var combos : Dictionary[InputAction, RCombo]
#var current_action : InputAction
#var current_combo : RCombo
#var current_anim_index := 0
#var current_combo_state : ComboState = ComboState.NONE
#
#var timer := Timer.new()
#
#func _ready() -> void:
	#player_controller.attack_triggered.connect(_on_attack_triggered)
	#add_child(timer)
	#timer.timeout.connect(on_timer_timeout)
	#attack_area.body_entered.connect(cast_attack)
#
#func cast_attack(p_body: Node3D) -> void:
	#if not p_body is CharacterBody3D or p_body == own_body:
		#return
	#var health_component : CHealth = p_body.get_node_or_null("Health")
	#if not health_component:
		#return
	#health_component.take_damage(10)
#
##
##func get_attack_animation() -> StringName:
	##var animation_name := attack_animations[attack_animation_idx]
	##timer.wait_time = animation_player.get_animation(animation_name).length + 0.5
	##timer.start()
	##attack_animation_idx += 1
	##if attack_animation_idx >= attack_animations.size():
		##_reset_animation_index()
	##return animation_name
#
#func advance_animation_index() -> void:
	#current_anim_index += 1
	#if current_anim_index >= current_combo.combo_animations.size():
		#current_anim_index = 0
#
#func start_timer() -> void:
	#timer.start(current_combo.get_wait_time(current_anim_index, current_combo_state))
	#print(current_combo.get_wait_time(current_anim_index, current_combo_state))
#func on_timer_timeout() -> void:
	#if current_combo_state == ComboState.PLAYING_ANIMATION:
		#advance_state()
		#start_timer()
	#else:
		#reset_current_action()
#
#func reset_current_action() -> void:
	#current_action = null
	#current_combo = null
	#current_anim_index = 0
	#current_combo_state = ComboState.NONE
#
#func set_current_action(p_action: InputAction) -> void:
	#current_action = p_action
	#current_combo = combos[p_action]
#
#func is_new_action(p_action: InputAction) -> bool:
	#if p_action != current_action:
		#return true
	#return false
#
#func advance_state() -> void:
	##test
	#
	#####
	#current_combo_state += 1
	#if current_combo_state == ComboState.AWAITING_COMBO:
		#current_combo_state = ComboState.NONE
	#print(ComboState.keys()[current_combo_state])
#
#func _on_attack_triggered(p_action: InputAction) -> void:
	## Not attacking
	#if current_combo_state == ComboState.PLAYING_ANIMATION:
		#return
	#
	#if is_new_action(p_action):
		#reset_current_action()
		#set_current_action(p_action)
	#else:
		## IF it's not a new attack then advance the animation index
		#advance_animation_index()
	## start timer for new anim
	#start_timer()
	#var attack_node := ((animation_tree.tree_root as AnimationNodeBlendTree).get_node("Attack") as AnimationNodeAnimation)
	#attack_node.animation = current_combo.get_animation(current_anim_index)
	#print(current_combo.get_animation(current_anim_index))
	#
	#animation_tree.set("parameters/AttackOS/request", AnimationNodeOneShot.OneShotRequest.ONE_SHOT_REQUEST_FIRE)
	#advance_state()
	##return
	##animation_tree.set("parameters/Attack/attack_triggered", true)
	#
	##if is_attacking():
		##return
	##(tree_root.get_node("Attack") as AnimationNodeAnimation).animation = get_attack_animation()
