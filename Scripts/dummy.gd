extends Node3D

@onready var mesh : MeshInstance3D = $MeshInstance3D
var original_color: Color
signal damaged

func _ready() -> void:
	pass
	#print("Inimigo na cena!")
	#original_color = (mesh.get_active_material(0) as ShaderMaterial).albedo_color
	
func take_damage() -> void:
	print("Inimigo foi atingido!")
	emit_signal("damaged")
	queue_free()
	
	
