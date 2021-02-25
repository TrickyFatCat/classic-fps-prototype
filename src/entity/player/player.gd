class_name Player
extends Entity

const CAM_ROT_MIN : float = -90.0
const CAM_ROT_MAX : float = 90.0

var _move_direction : Vector3 = Vector3.ZERO
var _player_direction : Vector3 = Vector3.ZERO
var drag : float = 0.0
var velocity : Vector3 = Vector3.ZERO
var snap_vec : Vector3
var is_jumping = false

export var acceleration : float = 4.0
export var speed_max : float = 25.0
export var jump_force : float = 25.0
export var gravity : float = 60.0
export var mouse_sens : float = 0.1
export var ignore_rotation : bool = false

onready var camera : Camera = $Camera


func _init() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	drag = acceleration / speed_max


func _input(event: InputEvent) -> void:
	_rotate_camera(event)
	if event.is_action_pressed("jump"):
		_apply_jump()


func _process(delta: float) -> void:
	_calculate_move_direction()


func _physics_process(delta: float) -> void:
	var current_move_direction : Vector3 = _move_direction
	
	if _move_direction == Vector3.ZERO and (abs(velocity.x) != 0 or abs(velocity.z) != 0):
		current_move_direction = velocity.normalized()
	
	if not ignore_rotation:
		current_move_direction = current_move_direction.rotated(Vector3.UP, rotation.y)
	var drag_vec : Vector3 = Vector3(drag, 0, drag)
	velocity += acceleration * current_move_direction - velocity * drag_vec + gravity * Vector3.DOWN * delta
	velocity = move_and_slide(velocity, Vector3.UP)


func _rotate_camera(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera.rotation_degrees.x -= mouse_sens * event.get_relative().y
		rotation_degrees.y -= mouse_sens * event.get_relative().x
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, CAM_ROT_MIN, CAM_ROT_MAX)


func _calculate_move_direction() -> void:
	_move_direction.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	_move_direction.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	_move_direction = _move_direction.normalized()

func _apply_jump() -> void:
	if is_on_floor() :
		velocity.y = jump_force
