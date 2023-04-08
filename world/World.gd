extends Node3D

const _RAY_LENGTH: int = 4000

@onready var _fps := $FPS as Label
@onready var _camera := $Camera as Camera3D
@onready var _terrain := $Terrain as Terrain


func _process(_delta: float) -> void:
	_fps.text = str(Engine.get_frames_per_second())


func _physics_process(_delta: float) -> void:
	_handle_block_interaction("place", "add_block")
	_handle_block_interaction("dig", "remove_block")


func _handle_block_interaction(
	action: StringName,
	function_name: StringName,
) -> void:
	if not Input.is_action_just_released(action):
		return

	var mouse_position := get_viewport().get_mouse_position()

	var parameters := PhysicsRayQueryParameters3D.new()
	parameters.from = _camera.project_ray_origin(mouse_position)
	parameters.to = parameters.from +\
			_camera.project_ray_normal(mouse_position) * _RAY_LENGTH

	var space_state := get_world_3d().direct_space_state
	var result := space_state.intersect_ray(parameters)

	if not result.is_empty():
		_terrain.call(function_name, result["position"], result["normal"])
