class_name CMove extends Node

enum State {
	JUMP,
	FALL,
	GROUNDED
}

var state_as_string := {
	State.JUMP: "Jump",
	State.FALL: "Fall",
	State.GROUNDED: "Grounded"
}

var state : State
@export var character : NCharacter
@export var SPEED : float
@export var forward_node : Node3D
var normalized_speed : float
var forward_velocity : float

func get_state_as_string() -> String:
	return state_as_string[state]

func update(delta: float, move_input: Vector2) -> void:
	character.velocity.x = 0
	character.velocity.z = 0
	move_input = move_input.normalized()
	
	
	if move_input != Vector2.ZERO:
		var forward_node_basis := forward_node.global_transform.basis
		forward_node_basis.z.y = 0.0  # Remove vertical componen
		var dir_as_vec3 := Vector3(move_input.x, 0, move_input.y)
		var direction := (forward_node_basis * dir_as_vec3).normalized()
		# this moves it relative to forward_node direction
		character.velocity.x = SPEED * direction.x
		character.velocity.z = SPEED * direction.z
		
		var target_basis := Basis.looking_at(-direction, Vector3.UP)

		#mesh_pivot.global_basis = mesh_pivot.global_basis.slerp(target_basis, delta * TURN_SPEED)

	if not character.is_on_floor():
		character.velocity.y += character.get_gravity().y * delta
			#mesh_pivot.global_basis = mesh_pivot.global_basis.slerp(target_bas, delta * TURN_SPEED)

	character.move_and_slide()

	var speed : float = Vector2(character.velocity.x, character.velocity.z).length()
	normalized_speed = clampf(speed / SPEED, 0.0, 1.0)
	forward_velocity =  character.velocity.dot(character.transform.basis.z) / SPEED
	if character.velocity.y != 0:
		if character.velocity.y > 0:
			state = State.JUMP
		elif character.velocity.y < 0:
			state = State.FALL
	else:
		state = State.GROUNDED
