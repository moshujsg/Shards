class_name REvent extends Resource

@export var id : String
@export var data : REventData
@export var condition : Callable

func _init(p_id: String, p_data: REventData) -> void:
	id = p_id
	data = p_data
