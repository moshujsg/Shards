class_name CAnimationTree extends AnimationTree

signal attack_animation_finished

var playback : AnimationNodeStateMachinePlayback = get("parameters/StateMachine/playback")
var attack_node : AnimationNodeAnimation 
var is_playing_animation : bool
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
var timer : Timer
func _ready() -> void:
	attack_node = ((tree_root as AnimationNodeBlendTree).get_node("Attack") as AnimationNodeAnimation)
	#animation_finished.connect(_on_animation_finished)
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.autostart = false
	#timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	
#func _on_animation_finished(p_animation: String) -> void:
	print("Animation finished")
	#if not p_animation == current_animation:
		#print("Finished uninmportant animation " + p_animation)
		#return
	#print("finished " + p_animation)
	#current_animation = ""
	attack_animation_finished.emit()

func is_playing() -> bool:
	return is_playing_animation

func play_attack_animation(p_animation_name: String, p_animation: Animation) -> void:
	if not animation_player.has_animation(p_animation_name):
		push_error("Attack animation not found")
	print("Received animation request " + p_animation_name)
	attack_node.animation = p_animation_name
	set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	timer.start(p_animation.length)
	is_playing_animation = true

func _physics_process(delta: float) -> void:
	var node_playing := get("parameters/AttackOneShot/active") as bool
	if is_playing_animation and not node_playing:
		attack_animation_finished.emit()
		is_playing_animation = false
