class_name Terrain
extends Node3D

const Block := preload("res://terrain/Block.gd")

const _CHUNK_SIZE := Vector3i.ONE * 10
const _CUBE_SIZE :=  Vector3.ONE

@export var _size_in_chunks: Vector3i
@export var _material: StandardMaterial3D

var _blocks: Array[Array]
var _chunks: Array[Array]

var _size: Vector3i:
	get:
		return _size_in_chunks * _CHUNK_SIZE


func _ready() -> void:
	_generate_blocks()
	_generate_chunks()


func _generate_blocks() -> void:
	if _size.x <= 0 || _size.y <= 0 || _size.z <= 0:
		return

	_blocks = []
	_blocks.resize(_size.x)

	for x in _blocks.size():
		_blocks[x] = []
		_blocks[x].resize(_size.y)

		for y in _blocks[x].size():
			_blocks[x][y] = []
			_blocks[x][y].resize(_size.z)

			for z in _blocks[x][y].size():
				var block_type: Block.Type

				if y <= 2 * sin(0.25 * x) + 2 * sin(0.1 * z) + 25:
					block_type = Block.Type.DIRT
				else:
					block_type = Block.Type.AIR

				_blocks[x][y][z] = Block.Block.new(block_type)


func _generate_chunks() -> void:
	_chunks = []
	_chunks.resize(_size_in_chunks.x)

	for x in _size_in_chunks.x:
		_chunks[x] = []
		_chunks[x].resize(_size_in_chunks.y)

		for y in _size_in_chunks.y:
			_chunks[x][y] = []
			_chunks[x][y].resize(_size_in_chunks.z)

			for z in _size_in_chunks.z:
				var chunk := _generate_chunk(Vector3i(x, y, z))
				_chunks[x][y][z] = chunk
				add_child(chunk)


func _generate_chunk(chunk_position: Vector3i) -> Chunk:
	var chunk := Chunk.new()
	chunk._size = _CHUNK_SIZE
	chunk._cube_size = _CUBE_SIZE

	var blocks_limits := chunk_position * _CHUNK_SIZE

	chunk._blocks = _blocks
	chunk._blocks_limits = blocks_limits
	chunk._blocks_size = _size

	chunk.material_override = _material

	return chunk


func remove_block(world_position: Vector3, normal: Vector3) -> void:
	var block_position := _from_cube_position_to_block_position(
		world_position,
		normal,
	)

	_blocks[block_position.x][block_position.y][block_position.z].type = \
			Block.Type.AIR

	for x in _size_in_chunks.x:
		for y in _size_in_chunks.y:
			for z in _size_in_chunks.z:
				_chunks[x][y][z].generate_terrain()


func _from_cube_position_to_block_position(
	cube_position: Vector3,
	normal: Vector3,
) -> Vector3i:
	var block_position := _from_world_position_to_block_position(cube_position)

	if normal.x > 0:
		block_position.x -= 1

	if normal.y > 0:
		block_position.y -= 1

	if normal.z > 0:
		block_position.z -= 1

	return block_position


func _from_world_position_to_block_position(world_position: Vector3) -> Vector3i:
	return Vector3i(
		int(world_position.x / _CUBE_SIZE.x),
		int(world_position.y / _CUBE_SIZE.y),
		int(world_position.z / _CUBE_SIZE.z),
	)
