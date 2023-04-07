class_name Chunk
extends MeshInstance3D

const Block := preload("res://terrain/Block.gd")

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

const _CUBE_SIDE_VERTEX_COUNT: int = 4

@export var _size: Vector3i
@export var _cube_size: Vector3

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

var _blocks: Array[Array]
var _blocks_size: Vector3i
var _blocks_limits: Vector3i

var _mesh_arrays: Array


func _ready() -> void:
	_mesh_arrays.resize(Mesh.ARRAY_MAX)
	generate_terrain()


func generate_terrain() -> void:
	if _generate_mesh():
		_generate_collision()


func _generate_mesh() -> bool:
	_mesh_arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array()
	_mesh_arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array()
	_mesh_arrays[Mesh.ARRAY_INDEX] = PackedInt32Array()

	_generate_cubes()

	if _mesh_arrays[Mesh.ARRAY_VERTEX].size() <= 0:
		return false

	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _mesh_arrays)

	mesh = array_mesh

	return true


func _generate_cubes():
	for x in range(_blocks_limits.x, _blocks_limits.x + _size.x):
		for y in range(_blocks_limits.y, _blocks_limits.y + _size.y):
			for z in range(_blocks_limits.z, _blocks_limits.z + _size.z):
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

	if x + 1 < _blocks_size.x:
		if _blocks[x + 1][y][z].type == Block.Type.AIR:
			sides.append(CubeSide.RIGHT)

	if y - 1 >= 0:
		if _blocks[x][y - 1][z].type == Block.Type.AIR:
			sides.append(CubeSide.BOTTOM)

	if y + 1 < _blocks_size.y:
		if _blocks[x][y + 1][z].type == Block.Type.AIR:
			sides.append(CubeSide.TOP)

	if z - 1 >= 0:
		if _blocks[x][y][z - 1].type == Block.Type.AIR:
			sides.append(CubeSide.FRONT)

	if z + 1 < _blocks_size.z:
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
