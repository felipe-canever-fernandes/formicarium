class_name Blocks
extends Node

var _blocks: Array[Array] = []

var _size: Vector3i = Vector3i.ZERO:
	get = get_size


func _init(size: Vector3i) -> void:
	_size = size
	_generate_blocks()


func _generate_blocks() -> void:
	if get_size().x <= 0 or get_size().y <= 0 or get_size().z <= 0:
		return

	_blocks.resize(get_size().x)

	for x in _blocks.size():
		_blocks[x] = []
		_blocks[x].resize(get_size().y)

		for y in _blocks[x].size():
			_blocks[x][y] = []
			_blocks[x][y].resize(get_size().z)

			for z in _blocks[x][y].size():
				var block_type: Block.Type = Block.Type.AIR

				if y <= 2 * sin(0.25 * x) + 2 * sin(0.1 * z) + 30:
					block_type = Block.Type.DIRT

				_blocks[x][y][z] = Block.new(block_type)


func get_size() -> Vector3i:
	return _size


func get_block_at(position: Vector3i) -> Block:
	if (
			position.x < 0 or position.x >= _size.x
			or position.y < 0 or position.y >= _size.y
			or position.z < 0 or position.z >= _size.z
	):
		return null

	return _blocks[position.x][position.y][position.z]


func for_each_block(
		operation: Callable,
		starting_position: Vector3i = Vector3.ZERO,
		ending_position: Vector3i = _size,
) -> void:
	for x in range(starting_position.x, ending_position.x):
		for y in range(starting_position.y, ending_position.y):
			for z in range(starting_position.z, ending_position.z):
				var position: Vector3i = Vector3i(x, y, z)
				var block: Block = get_block_at(position)
				operation.call(position, block)


func get_visible_sides(position: Vector3i) -> Array[Cube.Side]:
	var sides: Array[Cube.Side] = []

	if position.x - 1 >= 0:
		if (
				_blocks[position.x - 1][position.y][position.z].type
				== Block.Type.AIR
		):
			sides.append(Cube.Side.LEFT)

	if position.x + 1 < _size.x:
		if (
				_blocks[position.x + 1][position.y][position.z].type
				== Block.Type.AIR
		):
			sides.append(Cube.Side.RIGHT)

	if position.y - 1 >= 0:
		if (
				_blocks[position.x][position.y - 1][position.z].type
				== Block.Type.AIR
		):
			sides.append(Cube.Side.BOTTOM)

	if position.y + 1 < _size.y:
		if (
				_blocks[position.x][position.y + 1][position.z].type
				== Block.Type.AIR
		):
			sides.append(Cube.Side.TOP)

	if position.z - 1 >= 0:
		if (
				_blocks[position.x][position.y][position.z - 1].type
				== Block.Type.AIR
		):
			sides.append(Cube.Side.FRONT)

	if position.z + 1 < _size.z:
		if (
				_blocks[position.x][position.y][position.z + 1].type
				== Block.Type.AIR
		):
			sides.append(Cube.Side.BACK)

	return sides
