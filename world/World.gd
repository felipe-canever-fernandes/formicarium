extends Node3D

const _RAY_LENGTH: int = 4000

@onready var _fps: Label = $FPS as Label
@onready var _camera: Camera3D = $Camera as Camera3D
@onready var _terrain: Terrain = $Terrain as Terrain
@onready var _ant: Ant = $Ant as Ant


func _ready() -> void:
	var ant_position: Vector3 = \
			_terrain.get_closest_position_to(_ant.position)

	_ant.position = ant_position


func _process(_delta: float) -> void:
	_fps.text = str(Engine.get_frames_per_second())
	_handle_selection()


func _handle_selection() -> void:
	if not Input.is_action_just_pressed("select"):
		return

	var result: Dictionary = _get_mouse_position_in_world()
	var collider: PhysicsBody3D = result["collider"]

	if not collider is Ant:
		return

	_ant.selected = not _ant.selected


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
