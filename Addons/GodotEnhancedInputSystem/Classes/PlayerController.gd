class_name PlayerController extends Node

signal on_action_triggered(action : InputAction)

@export var preset_mapping_contexts : Array[InputMappingContext]

var mapping_contexts : Array[InputMappingContext]
var ongoing_actions : Array[InputActionContainer] = []
var context_remove_queue: Array[InputMappingContext]

#func _ready() -> void:
	#for context in preset_mapping_contexts:
		#push_mapping_context(context)
	

func bind_action(p_action : InputAction, p_event: InputActionProperties.TriggerPhase,  p_function: Callable) -> void:
	if not p_action:
		push_error("tried to bind a function to a null action")
		return
	p_action.bind_action(p_event, p_function)

func _input(event: InputEvent) -> void:
	pass
	if event is InputEventMouseMotion:
		pass
	else:
		if event.is_echo():
			return
		var flag := false
		for mapping_context in mapping_contexts:
			for container in mapping_context.action_containers:
				var action_name := mapping_context.name + "_" + container.action.name
				if not event.is_action(action_name):
					continue
				var handled := handle_event(container, event, action_name)
				if handled:
					return

func handle_event(container: InputActionContainer, event: InputEvent, action_name: String) -> bool:
	var handled := false
	if not event.is_pressed():
		pass
	if event.is_action_pressed(action_name):
		if not container.is_being_processed():
			ongoing_actions.append(container)
			container.on_action_started(event)
			handled = false
	elif event.is_action_released(action_name):
		container.on_action_ended(event)
	return handled

func _process(delta: float) -> void:
	for container in ongoing_actions:
		container.update()
		if not container.is_being_processed():
			call_deferred("clear_ongoing_action", container)
	for context in context_remove_queue:
		_remove_mapping_context(context)
	context_remove_queue.clear()

func clear_ongoing_action(container: InputActionContainer) -> void:
	ongoing_actions.erase(container)

func push_mapping_context(p_mapping_context: InputMappingContext) -> void:
	if not p_mapping_context:
		push_error("Tried to push a mapping context but it was null")
		return
	p_mapping_context._load_actions()
	mapping_contexts.push_front(p_mapping_context)

func queue_context_for_removal(p_mapping_context: InputMappingContext) -> void:
	if p_mapping_context in context_remove_queue:
		push_warning("Tried to remove context already queued for removal")
		return
	context_remove_queue.append(p_mapping_context)

func _remove_mapping_context(p_mapping_context: InputMappingContext) -> void:
	mapping_contexts.erase(p_mapping_context)
	# Update stack_index for remaining contexts
	for action in p_mapping_context.action_containers:
		action.disconnect_properties()
	
	for action in ongoing_actions:
		if action in p_mapping_context.action_containers:
			action.reset()
			call_deferred("clear_ongoing_action", action)
