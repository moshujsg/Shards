class_name MainPlayerController extends PlayerController

signal player_jumped
signal attack_triggered(action: InputAction)

const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.010
const TURN_SPEED = 10

@export_group("Actions")
@export var ia_move_up: InputAction
@export var ia_move_down: InputAction
@export var ia_move_left: InputAction
@export var ia_move_right: InputAction
@export var ia_jump: InputAction
@export var ia_show_cursor: InputAction
@export var ia_capture_cursor: InputAction
@export var ia_attack: InputAction
@export var ia_ability_slot_1: InputAction

@export_group("Contexts")
@export var base_context: InputMappingContext
@export var visible_cursor_context: InputMappingContext
@export var combat_context: InputMappingContext

@export_group("Nodes")
@export var player : NPlayer 
@export var camera: Camera3D
@export var pivot: SpringArm3D
@export var attack_component : CAttackComponent
var move_input : Vector2

func _ready() -> void:
	#super._ready()
	push_mapping_context(base_context)
	push_mapping_context(combat_context)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Movement Context
	bind_action(ia_move_up, InputActionProperties.TriggerPhase.TRIGGERED, handle_move)
	bind_action(ia_move_left, InputActionProperties.TriggerPhase.TRIGGERED, handle_move)
	bind_action(ia_move_right, InputActionProperties.TriggerPhase.TRIGGERED, handle_move)
	bind_action(ia_move_down, InputActionProperties.TriggerPhase.TRIGGERED, handle_move)
	bind_action(ia_move_up, InputActionProperties.TriggerPhase.COMPLETED, handle_move)
	bind_action(ia_move_left, InputActionProperties.TriggerPhase.COMPLETED, handle_move)
	bind_action(ia_move_right, InputActionProperties.TriggerPhase.COMPLETED, handle_move)
	bind_action(ia_move_down, InputActionProperties.TriggerPhase.COMPLETED, handle_move)
	bind_action(ia_show_cursor, InputActionProperties.TriggerPhase.TRIGGERED, show_cursor)
	bind_action(ia_jump, InputActionProperties.TriggerPhase.TRIGGERED, jump)

	# Visible Cursor Context
	bind_action(ia_capture_cursor, InputActionProperties.TriggerPhase.TRIGGERED, capture_cursor)
	
	# Combat
	bind_action(ia_attack, InputActionProperties.TriggerPhase.TRIGGERED, cast_ability.bind(ia_attack))
	bind_action(ia_ability_slot_1, InputActionProperties.TriggerPhase.TRIGGERED, cast_ability.bind(ia_ability_slot_1))

func cast_ability(p_object: InputObject, p_action: InputAction) -> void:
	attack_component.handle_action(p_action)

func capture_cursor(p_action: InputObject) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	queue_context_for_removal(visible_cursor_context)
	push_mapping_context(base_context)
	push_mapping_context(combat_context)

func show_cursor(p_action: InputObject) -> void:
	Input.mouse_mode = Input.MouseMode.MOUSE_MODE_VISIBLE
	queue_context_for_removal(base_context)
	queue_context_for_removal(combat_context)
	push_mapping_context(visible_cursor_context)
	pass

func jump(p_action: InputObject) -> void:
	if player.is_on_floor():
		player.velocity.y += JUMP_VELOCITY
		player_jumped.emit()

func handle_move(object: InputObject) -> void:
	var value := object.get_value_as_vector2()
	if object.axis_order == InputActionProperties.AxisOrder.XY:
		move_input.x = value.x
	else:
		move_input.y = value.y

func _input(event: InputEvent) -> void:
	super._input(event)
	if event is InputEventMouseMotion:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			return
		var _event := event as InputEventMouseMotion
		# Horizontal rotation (yaw)
		player.rotation.y -= _event.relative.x * MOUSE_SENSITIVITY

		# Vertical rotation (pitch)
		var pitch := _event.relative.y * MOUSE_SENSITIVITY
		pitch = clamp(pitch, deg_to_rad(-80), deg_to_rad(80))
		pivot.rotation.x -= pitch
