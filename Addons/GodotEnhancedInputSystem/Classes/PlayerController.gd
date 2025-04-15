class_name PlayerController extends Node

signal on_action_triggered(action : InputAction)

@export var preset_mapping_contexts : Array[InputMappingContext]

var mapping_contexts : Array[InputMappingContext]
var ongoing_actions : Array[InputActionContainer] = []

#func _ready() -> void:
	#for context in preset_mapping_contexts:
		#push_mapping_context(context)
	

func bind_action(p_action : InputAction, p_event: InputActionProperties.TriggerPhase,  p_function: Callable) -> void:
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

func clear_ongoing_action(container: InputActionContainer) -> void:
	ongoing_actions.erase(container)

func push_mapping_context(p_mapping_context: InputMappingContext) -> void:
	p_mapping_context._load_actions()
	mapping_contexts.push_front(p_mapping_context)
	# Update stack_index for all contexts
	for i in range(mapping_contexts.size()):
		mapping_contexts[i].stack_index = i

func remove_mapping_context(p_mapping_context: InputMappingContext) -> void:
	var index := p_mapping_context.stack_index
	if not (index >= 0 and index < mapping_contexts.size()):
		return
	mapping_contexts.remove_at(index)
	
	# Update stack_index for remaining contexts
	for i in range(index, mapping_contexts.size()):
		mapping_contexts[i].stack_index -= 1
