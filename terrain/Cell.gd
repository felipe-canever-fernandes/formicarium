enum CellType {
	AIR,
	DIRT,
}

class Cell:
	var type: CellType


	func _init(initial_type: CellType) -> void:
		type = initial_type
