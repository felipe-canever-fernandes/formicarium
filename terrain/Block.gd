enum Type {
	NONE,
	AIR,
	DIRT,
}

class Block:
	var type: Type = Type.NONE


	func _init(initial_type: Type) -> void:
		type = initial_type
