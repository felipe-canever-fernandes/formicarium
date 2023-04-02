class_name Terrain
extends Node3D

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

const Cell := preload("res://terrain/Cell.gd")

@export var _cube_size: Vector3
@export var _terrain_size: Vector3i

var _cells: Array[Array]

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

@onready var _mesh := $Mesh


func _ready() -> void:
	_generate_cells()
	_generate_terrain()


func _generate_cells() -> void:
	assert(_terrain_size.x > 0)
	assert(_terrain_size.y > 0)
	assert(_terrain_size.z > 0)

	_cells = []
	_cells.resize(_terrain_size.x)

	for x in _cells.size():
		_cells[x] = []
		_cells[x].resize(_terrain_size.y)

		for y in _cells[x].size():
			_cells[x][y] = []
			_cells[x][y].resize(_terrain_size.z)

			for z in _cells[x][y].size():
				var cell_type: Cell.CellType

				if y <= 5:
					cell_type = Cell.CellType.DIRT
				else:
					cell_type = Cell.CellType.AIR

				_cells[x][y][z] = Cell.Cell.new(cell_type)


func _generate_terrain() -> void:
	var mesh_arrays := []
	mesh_arrays.resize(Mesh.ARRAY_MAX)

	mesh_arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array()
	mesh_arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array()
	mesh_arrays[Mesh.ARRAY_INDEX] = PackedInt32Array()

	_generate_cube(mesh_arrays, Vector3(0, 0, 0))
	_generate_cube(mesh_arrays, Vector3(2, 0, 0))
	_generate_cube(mesh_arrays, Vector3(0, 0, 2))
	_generate_cube(mesh_arrays, Vector3(2, 0, 2))
	_generate_cube(mesh_arrays, Vector3(1, 0, 1))

	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)

	_mesh.mesh = array_mesh


func _generate_cube(mesh_arrays: Array, cube_position: Vector3):
	assert(_cube_size.x > 0)
	assert(_cube_size.y > 0)
	assert(_cube_size.z > 0)

	var sides: Array[CubeSide] = [
		CubeSide.FRONT,
		CubeSide.RIGHT,
		CubeSide.BACK,
		CubeSide.LEFT,
		CubeSide.BOTTOM,
		CubeSide.TOP,
	]

	var total_vertex_count: int = mesh_arrays[Mesh.ARRAY_VERTEX].size()

	for side_index in sides.size():
		var side := sides[side_index]

		var vertex_count: int = _cube_sides_vertices[side].size()

		var vertices := PackedVector3Array()
		vertices.resize(vertex_count)

		var normals := PackedVector3Array()
		normals.resize(vertex_count)

		for vertex_index in vertex_count:
			vertices[vertex_index] = _cube_sides_vertices[side][vertex_index]\
					* _cube_size + cube_position

			normals[vertex_index] = _cube_sides_normals[side]

		mesh_arrays[Mesh.ARRAY_VERTEX].append_array(vertices)
		mesh_arrays[Mesh.ARRAY_NORMAL].append_array(normals)

		var indices := PackedInt32Array()
		indices.resize(CUBE_FACE_VERTEX_COUNT)

		for index_index in _cube_vertices_indices.size():
			indices[index_index] = _cube_vertices_indices[index_index]\
					+ side_index * vertex_count + total_vertex_count

		mesh_arrays[Mesh.ARRAY_INDEX].append_array(indices)
