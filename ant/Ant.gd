class_name Ant
extends CharacterBody3D

const _ROTATION_ANGLE: float = PI / 2

const _CLIMB_ANGLE: float = PI / 2

const _CLIMB_OFFSET: float = -0.2
const _DESCENT_OFFSET: float = 0

@export var _food_points: int:
	set = _set_food_points

@export var _movement_speed: float

@onready var _wall_sensor: RayCast3D = $WallSensor as RayCast3D
@onready var _ledge_sensor: RayCast3D = $LedgeSensor as RayCast3D

func _physics_process(_delta: float) -> void:
	_handle_movement()
	_handle_rotation()
	_handle_climbing()


func _handle_movement() -> void:
	if not Input.is_action_pressed("move_ant_forward"):
		return

	velocity = -basis.z * _movement_speed
	move_and_slide()


func _handle_rotation() -> void:
	var rotation_direction: int = 0

	if Input.is_action_just_pressed("rotate_ant_left"):
		rotation_direction = 1
	elif Input.is_action_just_pressed("rotate_ant_right"):
		rotation_direction = -1

	if rotation_direction != 0:
		rotate(basis.y, rotation_direction * _ROTATION_ANGLE)


func _handle_climbing() -> void:
	var surface: RayCast3D = null
	var direction: float = 0
	var offset: float = 0

	if _wall_sensor.is_colliding():
		surface = _wall_sensor
		direction = 1
		offset = _CLIMB_OFFSET
	elif _ledge_sensor.is_colliding():
		surface = _ledge_sensor
		direction = -1
		offset = _DESCENT_OFFSET
	else:
		return

	rotate(basis.x, direction * _CLIMB_ANGLE)
	position = surface.get_collision_point() + offset * basis.z


func _on_lifespan_timeout() -> void:
	_die()


func _on_food_points_timer_timeout() -> void:
	_food_points -= 1


func _die() -> void:
	queue_free()


func _set_food_points(value: int) -> void:
	_food_points = value

	if _food_points <= 0:
		_die()
