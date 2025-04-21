@tool
extends Camera3D

@onready var postprocess: MeshInstance3D = $Postprocess

@export var post_processing := true:
	set(p):
		if p:
			postprocess.show()
			post_processing = p
			var a := Vector3(-1, 1, 0).normalized()
			var b := Vector3(1, 0, 0).normalized()
			#print("dot: ", a.dot(b)) 
		else:
			postprocess.hide()
			post_processing = p
