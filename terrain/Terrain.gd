class_name Terrain
extends Node3D

const _CHUNK_SIZE: Vector3i = Vector3i.ONE * 3
const _CUBE_SIZE: Vector3 = Vector3.ONE


static func _from_cube_position_to_block_position(
		cube_position: Vector3,
		normal: Vector3,
) -> Vector3i:
	var block_position: Vector3i = (
			Terrain._from_world_position_to_block_position(cube_position)
	)

	if normal.x > 0:
		block_position.x -= 1

	if normal.y > 0:
		block_position.y -= 1

	if normal.z > 0:
		block_position.z -= 1

	return block_position


static func _from_cube_position_to_adjacent_block(
		cube_position: Vector3,
		normal: Vector3,
) -> Vector3i:
	var block_position: Vector3i = (
			Terrain._from_cube_position_to_block_position(
					cube_position,
					normal,
			)
	)

	var adjacent_block_position: Vector3i = block_position

	if normal.x != 0:
		adjacent_block_position.x += int(normal.x)
	elif normal.y != 0:
		adjacent_block_position.y += int(normal.y)
	elif normal.z != 0:
		adjacent_block_position.z += int(normal.z)

	return adjacent_block_position


static func _from_world_position_to_block_position(
		world_position: Vector3,
) -> Vector3i:
	return Vector3i(
		int(world_position.x / _CUBE_SIZE.x),
		int(world_position.y / _CUBE_SIZE.y),
		int(world_position.z / _CUBE_SIZE.z),
	)


@export var _size_in_chunks: Vector3i = Vector3i.ZERO
@export var _material: StandardMaterial3D = null

var _blocks: Blocks = null
var _pathfinder: Pathfinder = null
var _chunks: Array[Array] = []

var _size: Vector3i:
	get = _get_size

@onready var _chunks_node: Node3D = $Chunks


func _ready() -> void:
	_blocks = Blocks.new(_size)
	generate_paths()
	_generate_chunks()


func generate_paths() -> void:
	_pathfinder = Pathfinder.new(_blocks)


func _generate_chunks() -> void:
	_chunks.resize(_size_in_chunks.x)

	for x in _size_in_chunks.x:
		_chunks[x] = []
		_chunks[x].resize(_size_in_chunks.y)

		for y in _size_in_chunks.y:
			_chunks[x][y] = []
			_chunks[x][y].resize(_size_in_chunks.z)

			for z in _size_in_chunks.z:
				var chunk: Chunk = _generate_chunk(Vector3i(x, y, z))
				_chunks[x][y][z] = chunk
				_chunks_node.add_child(chunk)


func _generate_chunk(chunk_position: Vector3i) -> Chunk:
	var chunk: Chunk = Chunk.new()
	chunk._size = _CHUNK_SIZE
	chunk._cube_size = _CUBE_SIZE

	var blocks_limits: Vector3i = chunk_position * _CHUNK_SIZE

	chunk._blocks = _blocks
	chunk._blocks_limits = blocks_limits

	chunk.material_override = _material

	return chunk


func add_block(world_position: Vector3, normal: Vector3) -> void:
	_change_block(
			"_from_cube_position_to_adjacent_block",
			Block.Type.DIRT,
			world_position,
			normal,
	)


func remove_block(world_position: Vector3, normal: Vector3) -> void:
	_change_block(
			"_from_cube_position_to_block_position",
			Block.Type.AIR,
			world_position,
			normal,
	)


func _change_block(
		block_position_function_name: StringName,
		block_type: Block.Type,
		world_position: Vector3,
		normal: Vector3,
) -> void:
	var block_position: Vector3i = call(
			block_position_function_name,
			world_position,
			normal,
	)

	var block: Block = _blocks.get_block_at(block_position)

	block.type = block_type

	var chunk_position: Vector3i = _from_block_position_to_chunk_position(
			block_position,
	)

	var initial_chunk_position: Vector3i = chunk_position - Vector3i.ONE
	var final_chunk_position: Vector3i = chunk_position + Vector3i.ONE

	for x in range(
			initial_chunk_position.x,
			final_chunk_position.x + 1,
	):
		for y in range(
				initial_chunk_position.y,
				final_chunk_position.y + 1,
		):
			for z in range(
					initial_chunk_position.z,
					final_chunk_position.z + 1,
			):
				var x_difference: int = abs(chunk_position.x - x)
				var y_difference: int = abs(chunk_position.y - y)
				var z_difference: int = abs(chunk_position.z - z)

				if x_difference + y_difference + z_difference > 1:
					continue

				if not _is_chunk_position_inside_terrain(Vector3i(x, y, z)):
					continue

				_chunks[x][y][z].generate_terrain()


func _from_block_position_to_chunk_position(
		block_position: Vector3i,
) -> Vector3i:
	@warning_ignore("integer_division")
	return Vector3i(
		block_position.x / _CHUNK_SIZE.x,
		block_position.y / _CHUNK_SIZE.y,
		block_position.z / _CHUNK_SIZE.z,
	)

func _is_chunk_position_inside_terrain(chunk_position: Vector3i) -> bool:
	return (
			chunk_position.x >= 0 and chunk_position.x < _size_in_chunks.x
			and chunk_position.y >= 0 and chunk_position.y < _size_in_chunks.y
			and chunk_position.z >= 0 and chunk_position.z < _size_in_chunks.z
	)


func _get_size() -> Vector3i:
	return _size_in_chunks * _CHUNK_SIZE
