enum Type {
	AIR,
	DIRT,
}

class Block:
	var type: Type


	func _init(initial_type: Type) -> void:
		type = initial_type
