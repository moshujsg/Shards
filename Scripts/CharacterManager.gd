#class_name NCharacterManager extends Node3D
#
#var characters : Array[NCharacter]
#@export var vfx_manager : VFXManager
#func _ready() -> void:
	#for character in get_children():
		#if not character is NCharacter:
			#continue
		#characters.append(character)
	#connect_signals()
#
#func connect_signals() -> void:
	#for character in characters:
		#character.vfx_request.connect(_on_character_vfx_request)
#
#func _on_character_vfx_request(vfx: PackedScene) -> void:
	#vfx_manager.request_vfx.emit(vfx)
