class_name Ant
extends CharacterBody3D

enum State {
	IDLE,
	MOVING,
	ROTATING,
}

const _MINIMUM_TARGET_DISTANCE: float = 0.05
const _MINIMUM_TARGET_ANGLE: float = 0.05

const _MINIMUM_ROTATION_ANGLE: float = PI / 2

const _ROTATION_ANGLE: float = PI / 2

const _CLIMB_ANGLE: float = PI / 2

const _CLIMB_OFFSET: float = -0.2
const _DESCENT_OFFSET: float = 0

@export var _food_points: int:
	set = _set_food_points

@export var _movement_speed: float = 0

var target_path: PackedVector3Array = []:
	set = set_target_path

var _target_position: Vector3 = Vector3.ZERO:
	set = _set_target_position

var _state: State = State.IDLE
var _target_path_index: int = 0

var _direction_projection_on_basis: Vector3 = Vector3.ZERO

@onready var _wall_sensor: RayCast3D = $WallSensor as RayCast3D
@onready var _ledge_sensor: RayCast3D = $LedgeSensor as RayCast3D


func _physics_process(_delta: float) -> void:
	match _state:
		State.MOVING:
			_move()
			_handle_climbing()
		State.ROTATING:
			_rotate()


func _move() -> void:
	if position.distance_to(self._target_position) <= _MINIMUM_TARGET_DISTANCE:
		position = self._target_position

		if _target_path_index + 1 == target_path.size():
			_state = State.IDLE
		else:
			_target_path_index += 1
			self._target_position = target_path[_target_path_index]

		return

	var direction_to_target: Vector3 = \
			position.direction_to(self._target_position)

	_direction_projection_on_basis = \
			(direction_to_target - direction_to_target.project(basis.y)).\
			normalized()

	if basis.z.angle_to(-_direction_projection_on_basis) \
			>= _MINIMUM_ROTATION_ANGLE:
		_state = State.ROTATING
		return

	var movement_direction: Vector3 = \
			direction_to_target.project(-basis.z).normalized()

	velocity = movement_direction * _movement_speed
	move_and_slide()


func _rotate() -> void:
	var angle: float = 0

	if _direction_projection_on_basis.angle_to(basis.z) \
			<= _MINIMUM_TARGET_ANGLE:
		angle = 2 * _ROTATION_ANGLE
	elif _direction_projection_on_basis.angle_to(basis.x) \
			<= _MINIMUM_TARGET_ANGLE:
		angle = -_ROTATION_ANGLE
	else:
		angle = _ROTATION_ANGLE

	rotate(basis.y, angle)

	_state = State.MOVING


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


func set_target_path(value: PackedVector3Array) -> void:
	_target_path_index = 0
	target_path = value

	if target_path.size() > 0:
		self._target_position = target_path[_target_path_index]


func _set_target_position(value: Vector3) -> void:
	_target_position = value
	_state = State.MOVING
