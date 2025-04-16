class_name CHealth extends Node

signal on_damage_taken(p_damage: int)

@export var body : CharacterBody3D
@onready var collision_shape_3d: CollisionShape3D = $"../CollisionShape3D"

@export var max_health := 100
var health := max_health

func take_damage(p_damage: int) -> void:
	health -= p_damage
	health = max(health, 0)
	if health == 0:
		print("Character dead")
	print("HP remaining " + str(health))
	on_damage_taken.emit(p_damage)
