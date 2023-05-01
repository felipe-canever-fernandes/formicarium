extends Node3D

const _RAY_LENGTH: int = 4000

@onready var _fps: Label = $FPS as Label
@onready var _camera: Camera3D = $Camera as Camera3D
@onready var _terrain: Terrain = $Terrain as Terrain
@onready var _ant: Ant = $Ant as Ant


func _process(_delta: float) -> void:
	_fps.text = str(Engine.get_frames_per_second())


func _physics_process(_delta: float) -> void:
	_handle_block_interaction("place", "add_block")
	_handle_block_interaction("dig", "remove_block")
	_handle_ant_movement()


func _handle_block_interaction(
	action: StringName,
	function_name: StringName,
) -> void:
	if not Input.is_action_just_released(action):
		return

	var result: Dictionary = _get_mouse_position_in_world()

	if result.is_empty():
		return

	var world_position: Vector3 = result["position"]
	var normal: Vector3 = result["normal"]
	_terrain.call(function_name, world_position, normal)


func _handle_ant_movement():
	if not Input.is_action_just_released("move_ant"):
		return

	var result: Dictionary = _get_mouse_position_in_world()

	if result.is_empty():
		return

	var world_position: Vector3 = result["position"]
	_ant.target_path = _terrain.get_path_from_to(_ant.position, world_position)


func _get_mouse_position_in_world() -> Dictionary:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()

	var parameters: PhysicsRayQueryParameters3D = (
			PhysicsRayQueryParameters3D.new()
	)

	parameters.from = _camera.project_ray_origin(mouse_position)

	parameters.to = (
			parameters.from
			+ _camera.project_ray_normal(mouse_position) * _RAY_LENGTH
	)

	var space_state: PhysicsDirectSpaceState3D = (
			get_world_3d().direct_space_state
	)

	var result: Dictionary = space_state.intersect_ray(parameters)
	return result
