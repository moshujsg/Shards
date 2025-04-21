class_name REventQueue extends Resource

@export var size := 64
var buffer: Array[REvent]
var head := 0
var tail := 0
var full := false

func _init(_size := 64) -> void:
	size = _size
	buffer = []
	buffer.resize(size)
	clear()

func push(item: REvent) -> void:
	if full:
		head = (head + 1) % size  # Overwrite oldest
	buffer[tail] = item
	tail = (tail + 1) % size
	full = head == tail

func pop() -> REvent:
	if is_empty():
		return null
	var item : REvent = buffer[head]
	buffer[head] = null
	head = (head + 1) % size
	full = false
	return item

func is_empty() -> bool:
	return not full and (head == tail)

func clear() -> void:
	head = 0
	tail = 0
	full = false
	for i in size:
		buffer[i] = null
