extends Camera3D

const MINIMUM_X_ROTATION: float = -90
const MAXIMUM_X_ROTATION: float = 90

@export var _movement_speed: float
@export var _rotation_speed: float

var _mouse_motion_delta := Vector2.ZERO


func _process(delta: float) -> void:
	_handle_movement(delta)
	_handle_rotation(delta)


func _handle_movement(delta: float) -> void:
	var direction := Vector3.ZERO

	if Input.is_action_pressed("forward"):
		direction.z += -1

	if Input.is_action_pressed("backward"):
		direction.z += 1

	if Input.is_action_pressed("strafe_left"):
		direction.x += -1

	if Input.is_action_pressed("strafe_right"):
		direction.x += 1

	if Input.is_action_pressed("strafe_down"):
		direction.y += -1

	if Input.is_action_pressed("strafe_up"):
		direction.y += 1

	var velocity := direction * _movement_speed * delta
	translate_object_local(velocity)


func _handle_rotation(delta: float) -> void:
	_mouse_motion_delta *= _rotation_speed * delta

	rotation_degrees.x = clamp(
		rotation_degrees.x + _mouse_motion_delta.y,
		MINIMUM_X_ROTATION,
		MAXIMUM_X_ROTATION,
	)

	rotation_degrees.y += _mouse_motion_delta.x

	_mouse_motion_delta = Vector2.ZERO


func _input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return

	if not Input.is_action_pressed("camera_rotation"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	var input_event_mouse_motion := event as InputEventMouseMotion

	_mouse_motion_delta.x -= input_event_mouse_motion.relative.x
	_mouse_motion_delta.y -= input_event_mouse_motion.relative.y
