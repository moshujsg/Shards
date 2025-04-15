class_name InputObject extends Object

var value : float
var modifiers : Array[InputActionProperties.Modifier]
var phase : InputActionProperties.TriggerPhase
var axis_order : InputActionProperties.AxisOrder
var vector_obj : Vector2

func initialize(p_modifiers: Array[InputActionProperties.Modifier]) -> void:
	modifiers = p_modifiers
	
func _set_value(p_value : float, p_phase: InputActionProperties.TriggerPhase) -> void:
	phase = p_phase
	value = p_value
	if modifiers.has(InputActionProperties.Modifier.NEGATE):
		value *= -1

func _reset() -> void:
	value = 0
	phase = InputActionProperties.TriggerPhase.STARTED

func get_value() -> float:
	return value

func get_value_as_bool() -> bool:
	return value as bool

func get_value_as_vector2() -> Vector2:
	vector_obj = Vector2.ZERO
	if axis_order == InputActionProperties.AxisOrder.XY:
		vector_obj.x = value
	elif axis_order == InputActionProperties.AxisOrder.YX:
		vector_obj.y = value
	return vector_obj
