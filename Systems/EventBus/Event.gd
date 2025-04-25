class_name REvent extends Resource

var id : String
var data : REventData
var condition : Callable

func _init(p_id: String, p_data: REventData) -> void:
	id = p_id
	data = p_data
