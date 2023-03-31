class_name Queen
extends Node3D


@export var _food_points : int:
	set(value):
		_food_points = value

		if _food_points <= 0:
			_die()


func _on_foodspan_timeout() -> void:
	_die()


func _on_food_points_timer_timeout() -> void:
		_food_points -= 1


func _die() -> void:
	queue_free()
