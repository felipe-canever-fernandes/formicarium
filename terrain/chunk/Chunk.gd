class_name Chunk
extends MeshInstance3D

const TRIANGLE_VERTEX_COUNT := 3
const CUBE_FACE_TRIANGLE_COUNT := 2

const CUBE_FACE_VERTEX_COUNT := TRIANGLE_VERTEX_COUNT * CUBE_FACE_TRIANGLE_COUNT

enum CubeSide {
	FRONT,
	RIGHT,
	BACK,
	LEFT,
	BOTTOM,
	TOP,
}

const Block := preload("res://terrain/Block.gd")

const _CUBE_SIDE_VERTEX_COUNT: int = 4

@export var _size: Vector3i
@export var _cube_size: Vector3

var _blocks: Array[Array]

var _cube_sides_vertices := [
	PackedVector3Array([
		Vector3(0, 0, 0),
		Vector3(1, 0, 0),
		Vector3(1, 1, 0),
		Vector3(0, 1, 0),
	]),

	PackedVector3Array([
		Vector3(1, 0, 0),
		Vector3(1, 0, 1),
		Vector3(1, 1, 1),
		Vector3(1, 1, 0),
	]),

	PackedVector3Array([
		Vector3(1, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 1, 1),
		Vector3(1, 1, 1),
	]),

	PackedVector3Array([
		Vector3(0, 0, 1),
		Vector3(0, 0, 0),
		Vector3(0, 1, 0),
		Vector3(0, 1, 1),
	]),

	PackedVector3Array([
		Vector3(0, 0, 1),
		Vector3(1, 0, 1),
		Vector3(1, 0, 0),
		Vector3(0, 0, 0),
	]),

	PackedVector3Array([
		Vector3(0, 1, 0),
		Vector3(1, 1, 0),
		Vector3(1, 1, 1),
		Vector3(0, 1, 1),
	]),
]

var _cube_vertices_indices := [
	0, 1, 3,
	1, 2, 3,
]

var _cube_sides_normals := [
	Vector3(0, 0, -1),
	Vector3(1, 0, 0),
	Vector3(0, 0, 1),
	Vector3(-1, 0, 0),
	Vector3(0, -1, 0),
	Vector3(0, 1, 0),
]

var _mesh_arrays: Array


func _ready() -> void:
	_mesh_arrays.resize(Mesh.ARRAY_MAX)

	_generate_blocks()
	_generate_terrain()


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

				if y <= 2 * sin(0.25 * x) + 2 * sin(0.1 * z) + 35:
					block_type = Block.Type.DIRT
				else:
					block_type = Block.Type.AIR

				_blocks[x][y][z] = Block.Block.new(block_type)


func _generate_terrain() -> void:
	_generate_mesh()
	_generate_collision()


func _generate_mesh() -> void:
	_mesh_arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array()
	_mesh_arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array()
	_mesh_arrays[Mesh.ARRAY_INDEX] = PackedInt32Array()

	_generate_cubes()

	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _mesh_arrays)

	mesh = array_mesh


func _generate_cubes():
	for x in _blocks.size():
		for y in _blocks[x].size():
			for z in _blocks[x][y].size():
				var block: Block.Block = _blocks[x][y][z]

				if block.type == Block.Type.AIR:
					continue

				var cube_position := Vector3(x, y, z) * _cube_size
				var sides := _get_cube_visible_sides(x, y, z)

				if sides.size() <= 0:
					continue

				_generate_cube(cube_position, sides)


func _get_cube_visible_sides(x: int, y: int, z: int) -> Array[CubeSide]:
	var sides: Array[CubeSide] = []

	if x - 1 >= 0:
		if _blocks[x - 1][y][z].type == Block.Type.AIR:
			sides.append(CubeSide.LEFT)

	if x + 1 < _size.x:
		if _blocks[x + 1][y][z].type == Block.Type.AIR:
			sides.append(CubeSide.RIGHT)

	if y - 1 >= 0:
		if _blocks[x][y - 1][z].type == Block.Type.AIR:
			sides.append(CubeSide.BOTTOM)

	if y + 1 < _size.y:
		if _blocks[x][y + 1][z].type == Block.Type.AIR:
			sides.append(CubeSide.TOP)

	if z - 1 >= 0:
		if _blocks[x][y][z - 1].type == Block.Type.AIR:
			sides.append(CubeSide.FRONT)

	if z + 1 < _size.z:
		if _blocks[x][y][z + 1].type == Block.Type.AIR:
			sides.append(CubeSide.BACK)

	return sides


func _generate_cube(
	cube_position: Vector3,
	sides: Array[CubeSide],
):
	assert(_cube_size.x > 0)
	assert(_cube_size.y > 0)
	assert(_cube_size.z > 0)

	var total_vertex_count: int = _mesh_arrays[Mesh.ARRAY_VERTEX].size()

	var vertices := PackedVector3Array()
	vertices.resize(_CUBE_SIDE_VERTEX_COUNT)

	var normals := PackedVector3Array()
	normals.resize(_CUBE_SIDE_VERTEX_COUNT)

	var indices := PackedInt32Array()
	indices.resize(CUBE_FACE_VERTEX_COUNT)

	for side_index in sides.size():
		var side := sides[side_index]

		for vertex_index in _CUBE_SIDE_VERTEX_COUNT:
			vertices[vertex_index] = _cube_sides_vertices[side][vertex_index]\
					* _cube_size + cube_position

			normals[vertex_index] = _cube_sides_normals[side]

		_mesh_arrays[Mesh.ARRAY_VERTEX].append_array(vertices)
		_mesh_arrays[Mesh.ARRAY_NORMAL].append_array(normals)

		for index_index in _cube_vertices_indices.size():
			indices[index_index] = _cube_vertices_indices[index_index]\
					+ side_index * _CUBE_SIDE_VERTEX_COUNT + total_vertex_count

		_mesh_arrays[Mesh.ARRAY_INDEX].append_array(indices)


func _generate_collision() -> void:
	if get_child_count() >= 1:
		var collision := get_child(0)
		collision.free()

	create_trimesh_collision()


func remove_block(world_position: Vector3, normal: Vector3) -> void:
	var block_position := _from_cube_position_to_block_position(
		world_position,
		normal,
	)

	_blocks[block_position.x][block_position.y][block_position.z].type = \
			Block.Type.AIR

	_generate_terrain()


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
		int(world_position.x / _cube_size.x),
		int(world_position.y / _cube_size.y),
		int(world_position.z / _cube_size.z),
	)


func _is_block_position_inside_chunk(block_position: Vector3i) -> bool:
	return block_position.x >= 0 and block_position.x < _size.x and \
			block_position.y >= 0 and block_position.y < _size.y and \
			block_position.z >= 0 and block_position.z < _size.z
