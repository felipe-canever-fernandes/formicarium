@tool
class_name Terrain
extends Node3D

const Cell := preload("res://terrain/Cell.gd")

@export var _cube_size: Vector3
@export var _terrain_size: Vector3i

var _cells: Array[Array]
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
	var mesh_arrays := _generate_cube()

	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)

	_mesh.mesh = array_mesh

func _generate_cube() -> Array:
	assert(_cube_size.x > 0)
	assert(_cube_size.y > 0)
	assert(_cube_size.z > 0)

	var mesh_arrays = []
	mesh_arrays.resize(Mesh.ARRAY_MAX)

	mesh_arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([
		# Face 1
		Vector3(0, 0, 0) * _cube_size,
		Vector3(1, 0, 0) * _cube_size,
		Vector3(1, 1, 0) * _cube_size,
		Vector3(0, 1, 0) * _cube_size,
		# Face 2
		Vector3(1, 0, 0) * _cube_size,
		Vector3(1, 0, 1) * _cube_size,
		Vector3(1, 1, 1) * _cube_size,
		Vector3(1, 1, 0) * _cube_size,
		# Face 3
		Vector3(1, 0, 1) * _cube_size,
		Vector3(0, 0, 1) * _cube_size,
		Vector3(0, 1, 1) * _cube_size,
		Vector3(1, 1, 1) * _cube_size,
		# Face 4
		Vector3(0, 0, 1) * _cube_size,
		Vector3(0, 0, 0) * _cube_size,
		Vector3(0, 1, 0) * _cube_size,
		Vector3(0, 1, 1) * _cube_size,
		# Face 5
		Vector3(0, 0, 1) * _cube_size,
		Vector3(1, 0, 1) * _cube_size,
		Vector3(1, 0, 0) * _cube_size,
		Vector3(0, 0, 0) * _cube_size,
		# Face 6
		Vector3(0, 1, 0) * _cube_size,
		Vector3(1, 1, 0) * _cube_size,
		Vector3(1, 1, 1) * _cube_size,
		Vector3(0, 1, 1) * _cube_size,
	])

	mesh_arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([
		# Face 1
		0, 1, 3,
		1, 2, 3,
		# Face 2
		4, 5, 7,
		5, 6, 7,
		# Face 3
		8, 9, 11,
		9, 10, 11,
		# Face 4
		12, 13, 15,
		13, 14, 15,
		# Face 4
		16, 17, 19,
		17, 18, 19,
		# Face 4
		20, 21, 23,
		21, 22, 23,
	])

	mesh_arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array([
		# Face 1
		Vector3(0, 0, -1),
		Vector3(0, 0, -1),
		Vector3(0, 0, -1),
		Vector3(0, 0, -1),
		# Face 2
		Vector3(1, 0, 0),
		Vector3(1, 0, 0),
		Vector3(1, 0, 0),
		Vector3(1, 0, 0),
		# Face 3
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		Vector3(0, 0, 1),
		# Face 4
		Vector3(-1, 0, 0),
		Vector3(-1, 0, 0),
		Vector3(-1, 0, 0),
		Vector3(-1, 0, 0),
		# Face 5
		Vector3(0, -1, 0),
		Vector3(0, -1, 0),
		Vector3(0, -1, 0),
		Vector3(0, -1, 0),
		# Face 6
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
		Vector3(0, 1, 0),
	])

	return mesh_arrays
