extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.10
const TURN_SPEED = 10

const TILT_ANGLE = 60.0
const TILT_SPEED = 5.0
const FORWARD_TILT_ANGLE = 15.0
const FORWARD_TILT_SPEED = 4.0


var coyote_time := 0.2 # tempo máximo para pular após sair do chão
var coyote_timer := 0.0


@onready var pivot = $Pivot
@onready var geometry = $Geometry
@onready var animation_player: AnimationPlayer = $Geometry/Player_v1/AnimationPlayer
@onready var animation_tree: AnimationTree = $Geometry/Player_v1/AnimationTree
@onready var debug_label: Label = $"../HUD/DebugLabel"
@onready var attack_area: Area3D = $Geometry/Area3D

func _ready():
	# Desativa a área no início do jogo
	attack_area.monitoring = false
	
	# Conecta o sinal de detecção de acerto
	attack_area.body_entered.connect(_on_attack_hit)

func _on_attack_hit(body: Node) -> void:
	if body.is_in_group("enemies"):
		body.connect("damaged", Callable(self, "_on_enemy_damaged"))
		body.take_damage()
		
func _on_enemy_damaged():
	debug_label.text = "Inimigo foi atingido!"

func _input(event): #para controlar entrada e saída do mouse no jogo
	if event is InputEventMouseButton: #esse evento é um click do mouse?
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED #se foi, capture o mouse
	elif Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE #se apertar esc, o mouse volta
	
	#Se o mouse está se movendo e o mouse está capturado:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		#para grirar a camera no eixo Y (horizontal), o mouse precisa mover no eixo X;
		#Convertemos a informação de movimentação do mouse de deg para rad com base no movimento relativo(com base na sua ultima posição) no eixo X;
		#deixamos negativo para inverter e multiplicamos por um valor pequeno (sensibilidade do mouse).
		rotate_y(deg_to_rad(-(event as InputEventMouseMotion).relative.x * MOUSE_SENSITIVITY))
		geometry.rotate_y(deg_to_rad((event as InputEventMouseMotion).relative.x * MOUSE_SENSITIVITY)) #rodar o player de volta (só removi o -)
		
		pivot.rotate_x(deg_to_rad(-(event as InputEventMouseMotion).relative.y * MOUSE_SENSITIVITY))
		pivot.rotation.x = deg_to_rad(clamp(rad_to_deg(pivot.rotation.x), -90, 90)) #limitando a rotação da camera.
	
	

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

# Atualiza o coyote timer
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	if Input.is_action_just_pressed("jump") and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0 # Zera após pular

	var input_dir := Input.get_vector("left", "right", "front", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		var rot = geometry.rotation
		geometry.look_at(Vector3(position.x, position.y, position.z) + direction)
		var target_y = geometry.rotation.y
		geometry.rotation = rot
		rot.y = lerp_angle(rot.y, target_y, delta * TURN_SPEED)
		geometry.rotation = rot
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	var target_tilt = 0.0
	
	
	
	#TILT LATERAL
	if direction:
	# Direção do movimento lateral em relação ao personagem
		var local_dir = geometry.to_local(position + direction) - geometry.to_local(position)
		target_tilt = clamp(local_dir.x, -1.0, 1.0) * -TILT_ANGLE
	else:
		target_tilt = 0.0
		
	var current_tilt = rad_to_deg(geometry.rotation.z)
	var new_tilt = lerp(current_tilt, target_tilt, delta * TILT_SPEED)
	geometry.rotation.z = deg_to_rad(new_tilt)
		
	
	# INCLINAÇÃO FRONTAL (X) AO SE MOVIMENTAR PRA FRENTE
	var target_forward_tilt = 0.0

	if direction:
	# Inclina pra frente ao se mover
		target_forward_tilt = deg_to_rad(-FORWARD_TILT_ANGLE) # negativo = inclina pra frente
	# Lerp suave no eixo X
	var current_forward_tilt = geometry.rotation.x
	var new_forward_tilt = lerp(current_forward_tilt, target_forward_tilt, delta * FORWARD_TILT_SPEED)
	geometry.rotation.x = new_forward_tilt
	
	
	# Ativar ataque (OneShot)
	if Input.is_action_just_pressed("attack"): 
		animation_tree.set("parameters/SwordAttack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

	update_animation(direction)

	move_and_slide()

# Atualiza as condições de animação com base no estado do jogador
func update_animation(direction: Vector3):
	if not is_on_floor():
		animation_tree.set("parameters/Moviment/transition_request", "Jump")
		debug_label.text = "Estado: Jumping"
	elif direction.length() > 0.1:
		animation_tree.set("parameters/Moviment/transition_request", "Run")
		debug_label.text = "Estado: Running"
	else:
		animation_tree.set("parameters/Moviment/transition_request", "Idle")
		debug_label.text = "Estado: Idle"
