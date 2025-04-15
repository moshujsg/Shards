class_name InputAction extends Resource

signal on_button_state_reset(action: InputAction)
signal on_event_fired(p_object: InputObject)

@export var name : String
@export var description : String


var bound_actions : Dictionary[InputActionProperties.TriggerPhase, Callable] = {
	InputActionProperties.TriggerPhase.TRIGGERED: Callable(),
	InputActionProperties.TriggerPhase.STARTED: Callable(),
	InputActionProperties.TriggerPhase.COMPLETED: Callable(),
	InputActionProperties.TriggerPhase.CANCELLED: Callable(),
	InputActionProperties.TriggerPhase.ONGOING: Callable()
}

func bind_action(p_event: InputActionProperties.TriggerPhase,  p_function: Callable) -> void:
	bound_actions[p_event] = p_function

func call_bind(p_object: InputObject) -> void:
	var target_callable := bound_actions[p_object.phase]
	if target_callable.is_null():
		return
	target_callable.call(p_object)
