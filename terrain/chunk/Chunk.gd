class_name Chunk
extends MeshInstance3D

const Block := preload("res://terrain/block.gd")

@export var _size: Vector3i = Vector3i.ZERO
@export var _cube_size: Vector3 = Vector3.ZERO

var _blocks: Array[Array] = []
var _blocks_size: Vector3i = Vector3i.ZERO
var _blocks_limits: Vector3i = Vector3i.ZERO

var _mesh_arrays: Array = []


func _ready() -> void:
	_mesh_arrays.resize(Mesh.ARRAY_MAX)
	generate_terrain()


func generate_terrain() -> void:
	var has_mesh: bool = _generate_mesh()
	_generate_collision(has_mesh)


func _generate_mesh() -> bool:
	_mesh_arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array()
	_mesh_arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array()
	_mesh_arrays[Mesh.ARRAY_INDEX] = PackedInt32Array()

	_generate_cubes()

	var array_mesh: ArrayMesh = ArrayMesh.new()
	var has_mesh: bool = false

	if _mesh_arrays[Mesh.ARRAY_VERTEX].size() > 0:
		has_mesh = true

		array_mesh.add_surface_from_arrays(
				Mesh.PRIMITIVE_TRIANGLES,
				_mesh_arrays,
		)

	mesh = array_mesh

	return has_mesh


func _generate_cubes():
	var starting_position: Vector3i = _blocks_limits
	var ending_position: Vector3i = starting_position + _size

	for x in range(starting_position.x, ending_position.x):
		for y in range(starting_position.y, ending_position.y):
			for z in range(starting_position.z, ending_position.z):
				var block: Block.Block = _blocks[x][y][z]

				if block.type == Block.Type.AIR:
					continue

				var cube_position: Vector3 = Vector3(x, y, z) * _cube_size
				var sides: Array[Cube.Side] = _get_cube_visible_sides(x, y, z)

				if sides.size() <= 0:
					continue

				_generate_cube(cube_position, sides)


func _get_cube_visible_sides(x: int, y: int, z: int) -> Array[Cube.Side]:
	var sides: Array[Cube.Side] = []

	if x - 1 >= 0:
		if _blocks[x - 1][y][z].type == Block.Type.AIR:
			sides.append(Cube.Side.LEFT)

	if x + 1 < _blocks_size.x:
		if _blocks[x + 1][y][z].type == Block.Type.AIR:
			sides.append(Cube.Side.RIGHT)

	if y - 1 >= 0:
		if _blocks[x][y - 1][z].type == Block.Type.AIR:
			sides.append(Cube.Side.BOTTOM)

	if y + 1 < _blocks_size.y:
		if _blocks[x][y + 1][z].type == Block.Type.AIR:
			sides.append(Cube.Side.TOP)

	if z - 1 >= 0:
		if _blocks[x][y][z - 1].type == Block.Type.AIR:
			sides.append(Cube.Side.FRONT)

	if z + 1 < _blocks_size.z:
		if _blocks[x][y][z + 1].type == Block.Type.AIR:
			sides.append(Cube.Side.BACK)

	return sides


func _generate_cube(
		cube_position: Vector3,
		sides: Array[Cube.Side],
):
	assert(_cube_size.x > 0)
	assert(_cube_size.y > 0)
	assert(_cube_size.z > 0)

	var total_vertex_count: int = _mesh_arrays[Mesh.ARRAY_VERTEX].size()

	var vertices: PackedVector3Array = PackedVector3Array()
	vertices.resize(Cube.SIDE_VERTEX_COUNT)

	var normals: PackedVector3Array = PackedVector3Array()
	normals.resize(Cube.SIDE_VERTEX_COUNT)

	var indices: PackedInt32Array = PackedInt32Array()
	indices.resize(Cube.FACE_VERTEX_COUNT)

	for side_index in sides.size():
		var side: Cube.Side = sides[side_index]

		for vertex_index in Cube.SIDE_VERTEX_COUNT:
			vertices[vertex_index] = (
					Cube.sides_vertices[side][vertex_index] * _cube_size
					+ cube_position
			)

			normals[vertex_index] = Cube.sides_normals[side]

		_mesh_arrays[Mesh.ARRAY_VERTEX].append_array(vertices)
		_mesh_arrays[Mesh.ARRAY_NORMAL].append_array(normals)

		for index_index in Cube.vertices_indices.size():
			indices[index_index] = (
					Cube.vertices_indices[index_index]
					+ side_index * Cube.SIDE_VERTEX_COUNT
					+ total_vertex_count
			)

		_mesh_arrays[Mesh.ARRAY_INDEX].append_array(indices)


func _generate_collision(has_mesh: bool) -> void:
	if get_child_count() >= 1:
		var collision: Object = get_child(0)
		collision.free()

	if has_mesh:
		create_trimesh_collision()
