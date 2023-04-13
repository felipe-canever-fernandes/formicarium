class_name Block

enum Type {
	NONE,
	AIR,
	DIRT,
}

var type: Type = Type.NONE


func _init(initial_type: Type) -> void:
	type = initial_type
