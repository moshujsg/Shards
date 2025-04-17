class_name InputMappingContext extends Resource

@export var name : String
@export var action_containers : Array[InputActionContainer]
var disabled : bool

func _load_actions() -> void:
	if name == "":
		push_error("InputMappingContext name is null")
	for container in action_containers:
		container._load_actions(name) 
