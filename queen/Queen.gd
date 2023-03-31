class_name Queen
extends Node3D


func _on_lifespan_timeout() -> void:
	queue_free()
