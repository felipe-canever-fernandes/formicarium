class_name Pathfinder
extends Node3D


class SideInformation:
	var block_position: Vector3i
	var side: Cube.Side


	func _init(
			initial_block_position: Vector3i,
			initial_side: Cube.Side,
	) -> void:
		block_position = initial_block_position
		side = initial_side


var _a_star: AStar3D = AStar3D.new()
var _blocks: Blocks = null
var _side_informations: Dictionary = {}


func _init(blocks: Blocks) -> void:
	_blocks = blocks
	_generate_paths()

func _generate_paths() -> void:
	var closure_variables: Dictionary = {"i": 0}

	_blocks.for_each_block(func(block_position: Vector3i, block: Block) -> void:
		if block.type == Block.Type.AIR:
			return

		var cube_position: Vector3 = block_position
		var sides: Array[Cube.Side] = _blocks.get_visible_sides(block_position)

		for side in sides:
			var side_position: Vector3 = \
					cube_position + Cube.sides_position_offsets[side]

			_a_star.add_point(closure_variables["i"], side_position)

			_side_informations[side_position] = SideInformation.new(
					block_position,
					side,
			)

			for id in _a_star.get_point_ids():
				if id == closure_variables["i"]:
					continue

				var other_position: Vector3 = _a_star.get_point_position(id)

				var other_side_information: SideInformation = \
						_side_informations[other_position]

				var distance: float = side_position.distance_to(other_position)

				if distance > 1:
					continue

				var other_side: Cube.Side = other_side_information.side

				if is_zero_approx(abs(distance - 1)):
					if side != other_side:
						continue

				var other_block_position: Vector3i = \
						other_side_information.block_position

				if block_position == other_block_position:
					var normal: Vector3 = Cube.sides_normals[side]
					var other_normal: Vector3 = Cube.sides_normals[other_side]

					var obstacle_direction: Vector3i = normal + other_normal

					var obstacle_position: Vector3i = \
							block_position + obstacle_direction

					var obstacle: Block = \
							_blocks.get_block_at(obstacle_position)

					if obstacle.type != Block.Type.AIR:
						continue

				_a_star.connect_points(closure_variables["i"], id)

			closure_variables["i"] += 1
	)


func get_path_from_to(from: Vector3, to: Vector3) -> PackedVector3Array:
	var from_id: int = _a_star.get_closest_point(from)
	var to_id: int = _a_star.get_closest_point(to)

	return _a_star.get_point_path(from_id, to_id)
