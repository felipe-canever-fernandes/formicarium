extends Node3D

const _RAY_LENGTH: int = 4000

@onready var _camera := $Camera as Camera3D
@onready var _terrain := $Terrain as Terrain


func _physics_process(_delta: float) -> void:
	_handle_digging()


func _handle_digging() -> void:
	if not Input.is_action_just_released("dig"):
		return

	var mouse_position := get_viewport().get_mouse_position()

	var parameters := PhysicsRayQueryParameters3D.new()
	parameters.from = _camera.project_ray_origin(mouse_position)
	parameters.to = parameters.from +\
			_camera.project_ray_normal(mouse_position) * _RAY_LENGTH

	var space_state := get_world_3d().direct_space_state
	var result := space_state.intersect_ray(parameters)

	if not result.is_empty():
		_terrain.remove_block(result["position"], result["normal"])
