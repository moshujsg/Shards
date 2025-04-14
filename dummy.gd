extends Node3D

@onready var mesh := $MeshInstance3D
var original_color: Color
signal damaged

func _ready():
	print("Inimigo na cena!")
	original_color = mesh.get_active_material(0).albedo_color
	
func take_damage():
	print("Inimigo foi atingido!")
	emit_signal("damaged")
	queue_free()
	
	
