class_name InputActionContainer extends Resource


@export var action : InputAction
@export var action_properties : Array[InputActionProperties]
var ongoing_prop : InputActionProperties

func connect_properties() -> void:
	for property in action_properties:
		property.internal_event_fire.connect(_on_internal_event_fired)

func disconnect_properties() -> void:
	for property in action_properties:
		if not property.internal_event_fire.is_connected(_on_internal_event_fired):
			continue
		property.internal_event_fire.disconnect(_on_internal_event_fired)

func _on_internal_event_fired(p_object: InputObject) -> void:
	action.call_bind(p_object)
	action.on_event_fired.emit(p_object)

func _load_actions(context_prefix : String) -> void:
	var action_name : String = context_prefix + "_" + action.name
	if InputMap.has_action(action_name):
		InputMap.erase_action(action_name)
	InputMap.add_action(action_name)
	for action_property in action_properties:
		InputMap.action_add_event(action_name, action_property.event)
		action_property._setup()

func on_action_started(event: InputEvent) -> void:
	# Can't start new prop if already existing one
	if ongoing_prop != null:
		return
	for property in action_properties:
		if not property.event.is_match(event):
			continue
		property.next_state = InputActionProperties.State.PRESS
		ongoing_prop = property
		connect_properties()

func is_event_ongoing_property(event: InputEvent) -> bool:
	if ongoing_prop == null or not ongoing_prop.event.is_match(event):
		return false
	return true
	
func on_action_ended(event: InputEvent) -> void:
	if ongoing_prop == null or not event.is_match(ongoing_prop.event):
		return
	ongoing_prop.next_state = InputActionProperties.State.RELEASE

func update() -> void:
	if ongoing_prop:
		ongoing_prop.update()
		if not ongoing_prop.is_being_processed():
			disconnect_properties()
			ongoing_prop = null
	
func is_being_processed() -> bool:
	if ongoing_prop:
		return true
	return false

func reset() -> void:
	if ongoing_prop:
		ongoing_prop.reset()
		ongoing_prop = null
