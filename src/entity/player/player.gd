class_name Player
extends Entity

const CAM_ROT_MIN : float = -90.0
const CAM_ROT_MAX : float = 90.0

var _move_direction : Vector3 = Vector3.ZERO
var _player_direction : Vector3 = Vector3.ZERO
var velocity : Vector3 = Vector3.ZERO
var snap_vec : Vector3
var is_jumping = false

export var acceleration : float = 500.0
export var speed_max : float = 25.0
export var ground_friction : float = 100.0
export var air_friction : float = 25.0
export var jump_force : float = 25.0
export var gravity : float = 60.0
export var mouse_sens : float = 0.1
export var ignore_rotation : bool = false

onready var camera : Camera = $Camera


func _init() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	_rotate_camera(event)
	if event.is_action_pressed("jump"):
		_apply_jump()


func _process(delta: float) -> void:
	_calculate_move_direction()


func _physics_process(delta: float) -> void:
	var current_direction = _move_direction
	if not ignore_rotation:
		_move_direction = _move_direction.rotated(Vector3.UP, rotation.y)
	
	_calculate_velocity_x(_move_direction)
	_calculate_velocity_z(_move_direction)
	_apply_gravity()
	velocity = move_and_slide(velocity, Vector3.UP)
	
	$Label.text = String(velocity)


func _rotate_camera(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera.rotation_degrees.x -= mouse_sens * event.get_relative().y
		rotation_degrees.y -= mouse_sens * event.get_relative().x
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, CAM_ROT_MIN, CAM_ROT_MAX)


func _calculate_move_direction() -> void:
	_move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	_move_direction.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	_move_direction = _move_direction.normalized()


func _calculate_velocity_x(direction: Vector3) -> void:
	if direction.x != 0 and abs(velocity.x) <= speed_max:
		velocity.x += acceleration * direction.x * get_physics_process_delta_time()
		velocity.x = clamp(velocity.x, -speed_max, speed_max)
	elif velocity.x != 0 or abs(velocity.x) > speed_max:
		direction.x = -sign(velocity.x)
		var friction = ground_friction if is_on_floor() else air_friction
		velocity.x += friction * direction.x * get_physics_process_delta_time()
		
		if direction.x < 0:
			velocity.x = max(velocity.x, 0)
		elif direction.x > 0:
			velocity.x = min(velocity.x, 0)


func _calculate_velocity_z(direction: Vector3) -> void:
	if direction.z != 0 and abs(velocity.z) <= speed_max:
		velocity.z += acceleration * direction.z * get_physics_process_delta_time()
		velocity.z = clamp(velocity.z, -speed_max, speed_max)
	elif velocity.z != 0 or abs(velocity.z) > speed_max:
		direction.z = -sign(velocity.z)
		var friction = ground_friction if is_on_floor() else air_friction
		velocity.z += friction * direction.z * get_physics_process_delta_time()
		
		if direction.z < 0:
			velocity.z = max(velocity.z, 0)
		elif direction.z > 0:
			velocity.z = min(velocity.z, 0)


func _apply_gravity() -> void:
	velocity.y -= gravity * get_physics_process_delta_time()


func _apply_jump() -> void:
	if is_on_floor() :
		velocity.y = jump_force
