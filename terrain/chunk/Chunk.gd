class_name Chunk
extends MeshInstance3D

@export var _size: Vector3i = Vector3i.ZERO
@export var _cube_size: float = 0

var _blocks: Blocks = null
var _blocks_limits: Vector3i = Vector3i.ZERO

var _mesh_arrays: Array = []


func _init(
	size: Vector3i,
	cube_size: float,
	blocks: Blocks,
	blocks_limits: Vector3i,
	material: Material,
) -> void:
	_size = size
	_cube_size = cube_size
	_blocks = blocks
	_blocks_limits = blocks_limits
	material_override = material

	_mesh_arrays.resize(Mesh.ARRAY_MAX)


func _ready() -> void:
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

	var operation: Callable = func(
			block_position: Vector3i,
			block: Block
	) -> void:
		if block.type == Block.Type.AIR:
			return

		var cube_position: Vector3 = Vector3(block_position) * _cube_size

		var sides: Array[Cube.Side] = \
				_blocks.get_visible_sides(block_position)

		if sides.size() <= 0:
			return

		_generate_cube(cube_position, sides)

	_blocks.for_each_block(operation, starting_position, ending_position)


func _generate_cube(
		cube_position: Vector3,
		sides: Array[Cube.Side],
):
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
