class_name Blocks
extends Node

var _size: Vector3i = Vector3i.ZERO:
	get = get_size

var blocks: Array[Array] = []


func _init(size: Vector3i) -> void:
	_size = size
	_generate_blocks()


func _generate_blocks() -> void:
	if get_size().x <= 0 or get_size().y <= 0 or get_size().z <= 0:
		return

	blocks.resize(get_size().x)

	for x in blocks.size():
		blocks[x] = []
		blocks[x].resize(get_size().y)

		for y in blocks[x].size():
			blocks[x][y] = []
			blocks[x][y].resize(get_size().z)

			for z in blocks[x][y].size():
				var block_type: Block.Type = Block.Type.AIR

				if y <= 2 * sin(0.25 * x) + 2 * sin(0.1 * z) + 30:
					block_type = Block.Type.DIRT

				blocks[x][y][z] = Block.new(block_type)


func get_size() -> Vector3i:
	return _size
