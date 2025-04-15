class_name MainPlayerController extends PlayerController

signal player_jumped

enum State {
}

const TILT_ANGLE = 60.0
const TILT_SPEED = 5.0
const FORWARD_TILT_ANGLE = 15.0
const FORWARD_TILT_SPEED = 4.0

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.010
const TURN_SPEED = 10

@export var ia_move_up: InputAction
@export var ia_move_down: InputAction
@export var ia_move_left: InputAction
@export var ia_move_right: InputAction
@export var ia_jump: InputAction
@export var ia_capture_mouse: InputAction
@export var base_context: InputMappingContext

@onready var player : Player = owner
@onready var camera: Camera3D = $"../Pivot/Camera3D"
@onready var pivot: SpringArm3D = $"../Pivot"
@onready var mesh: Node3D = $"../Mesh"

var move_input : Vector2

func _ready() -> void:
	#super._ready()
	push_mapping_context(base_context)
	bind_action(ia_move_up, InputActionProperties.TriggerPhase.TRIGGERED, on_action)
	bind_action(ia_move_left, InputActionProperties.TriggerPhase.TRIGGERED, on_action)
	bind_action(ia_move_right, InputActionProperties.TriggerPhase.TRIGGERED, on_action)
	bind_action(ia_move_down, InputActionProperties.TriggerPhase.TRIGGERED, on_action)
	bind_action(ia_capture_mouse, InputActionProperties.TriggerPhase.TRIGGERED, toggle_mouse_capture)
	bind_action(ia_capture_mouse, InputActionProperties.TriggerPhase.COMPLETED, toggle_mouse_capture)
	bind_action(ia_jump, InputActionProperties.TriggerPhase.TRIGGERED, jump)

func toggle_mouse_capture(p_action: InputObject) -> void:
	if Input.mouse_mode == Input.MouseMode.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MouseMode.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MouseMode.MOUSE_MODE_CAPTURED

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
	
	player.movement_state = Player.MovementState.IDLE
	
	if move_input != Vector2.ZERO:
		var camera_basis := camera.global_transform.basis
		camera_basis.z.y = 0.0  # Remove vertical componen
		var dir_as_vec3 := Vector3(move_input.x, 0, move_input.y)
		var direction := (camera_basis * dir_as_vec3).normalized()
		# this moves it relative to camera direction
		player.velocity.x = SPEED * direction.x
		player.velocity.z = SPEED * direction.z
		
		var target_basis := Basis.looking_at(-direction, Vector3.UP)

		mesh.global_basis = mesh.global_basis.slerp(target_basis, delta * TURN_SPEED)
		player.movement_state = Player.MovementState.RUN

		#if not player.is_on_floor():
			#print(target_basis)
			## Determine turn amount (how sharp the turn is)
			#var turn_strength := clampf(target_basis.z.y, -1.0, 1.0) # only Y matters for horizontal turn
#
			## Calculate tilt amount (left/right based on turn direction)
			#var tilt_angle := deg_to_rad(TILT_ANGLE) * 1.0
#
			## Create a tilted version of the target_basis
			#var tilt_basis := target_basis.rotated(target_basis.z, tilt_angle * signf(target_basis.z.y))
#
			## Apply smooth tilt (only if airborne)
			#mesh.global_basis = mesh.global_basis.slerp(tilt_basis, delta * TILT_SPEED)

	if not player.is_on_floor():
		player.velocity.y += player.get_gravity().y * delta
		player.movement_state = Player.MovementState.JUMP

			#mesh.global_basis = mesh.global_basis.slerp(target_bas, delta * TURN_SPEED)

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
