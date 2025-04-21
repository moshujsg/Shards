extends Node


@export var _listeners : Dictionary[String, Array]
@export var event_queue : REventQueue = REventQueue.new()

func _physics_process(delta: float) -> void:
	while not event_queue.is_empty():
		var event := event_queue.pop()
		if not _listeners.has(event.id):
			continue
		call_listeners(event)


func broadcast(event_id: String, event_data: REventData) -> void:
	var new_event := REvent.new(event_id, event_data)
	event_queue.push(new_event)

func is_listening(event_id: String, callable: Callable) -> bool:
	return (_listeners.get(event_id) as Array).has(callable)

func on(event_id: String, callable: Callable) -> void:
	if not _listeners.has(event_id):
		_listeners[event_id] = [callable]
	if is_listening(event_id, callable):
		#push_error("Trying to subscribe to " + event_id + " but already subscribed")
		return
	(_listeners.get(event_id) as Array).append(callable)

func off(event_id: String, callable: Callable) -> void:
	if not _listeners.has(event_id):
		push_error("Trying to unsubscribe to " + event_id + " but it doesn't exist")
		return
	if not is_listening(event_id, callable):
		push_error("Trying to unsubscribe to " + event_id + " but already unsubscribed")
		return
	(_listeners.get(event_id) as Array).append(callable)

func clear_listeners(event_id: String) -> void:
	if not _listeners.has(event_id):
		push_error("Trying to clear " + event_id + " but it doesn't exist")
		return
	(_listeners.get(event_id) as Array).clear()

func call_listeners(event: REvent) -> void:
	for callable in _listeners.get(event.id) as Array[Callable]:
		callable.call(event.data)
