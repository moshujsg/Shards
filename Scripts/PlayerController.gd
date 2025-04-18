class_name MainPlayerController extends PlayerController

signal player_jumped
signal attack_triggered(action: InputAction)

const TILT_ANGLE = 60.0
const TILT_SPEED = 5.0
const FORWARD_TILT_ANGLE = 15.0
const FORWARD_TILT_SPEED = 4.0

const SPEED = 5.0
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

@export var player : NPlayer 
@export var camera: Camera3D
@export var pivot: SpringArm3D
@export var mesh_pivot: Node3D

var move_input : Vector2

func _ready() -> void:
	#super._ready()
	push_mapping_context(base_context)
	push_mapping_context(combat_context)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Movement Context
	bind_action(ia_move_up, InputActionProperties.TriggerPhase.TRIGGERED, on_action)
	bind_action(ia_move_left, InputActionProperties.TriggerPhase.TRIGGERED, on_action)
	bind_action(ia_move_right, InputActionProperties.TriggerPhase.TRIGGERED, on_action)
	bind_action(ia_move_down, InputActionProperties.TriggerPhase.TRIGGERED, on_action)
	bind_action(ia_show_cursor, InputActionProperties.TriggerPhase.TRIGGERED, show_cursor)
	bind_action(ia_jump, InputActionProperties.TriggerPhase.TRIGGERED, jump)

	# Visible Cursor Context
	bind_action(ia_capture_cursor, InputActionProperties.TriggerPhase.TRIGGERED, capture_cursor)
	
	# Combat
	bind_action(ia_attack, InputActionProperties.TriggerPhase.TRIGGERED, cast_ability.bind(ia_attack))
	bind_action(ia_ability_slot_1, InputActionProperties.TriggerPhase.TRIGGERED, cast_ability.bind(ia_ability_slot_1))

func cast_ability(p_object: InputObject, p_action: InputAction) -> void:
	attack_triggered.emit(p_action)

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

func on_action(object: InputObject) -> void:
	move_input += object.get_value_as_vector2()

func _physics_process(delta: float) -> void:
	player.velocity.x = 0
	player.velocity.z = 0
	move_input = move_input.normalized()
	
	
	if move_input != Vector2.ZERO:
		var camera_basis := camera.global_transform.basis
		camera_basis.z.y = 0.0  # Remove vertical componen
		var dir_as_vec3 := Vector3(move_input.x, 0, move_input.y)
		var direction := (camera_basis * dir_as_vec3).normalized()
		# this moves it relative to camera direction
		player.velocity.x = SPEED * direction.x
		player.velocity.z = SPEED * direction.z
		
		var target_basis := Basis.looking_at(-direction, Vector3.UP)

		#mesh_pivot.global_basis = mesh_pivot.global_basis.slerp(target_basis, delta * TURN_SPEED)

	if not player.is_on_floor():
		player.velocity.y += player.get_gravity().y * delta
			#mesh_pivot.global_basis = mesh_pivot.global_basis.slerp(target_bas, delta * TURN_SPEED)

	player.move_and_slide()
	move_input.x = 0
	move_input.y = 0

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
