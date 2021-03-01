class_name Player
extends Entity

const CAM_ROT_MIN : float = -90.0
const CAM_ROT_MAX : float = 90.0

var _move_direction : Vector3 = Vector3.ZERO
var _player_direction : Vector3 = Vector3.ZERO
var _velocity_horizontal : Vector3 = Vector3.ZERO
var _velocity_vertical : Vector3 = Vector3.ZERO
var health_node : BaseResource

export var acceleration : float = 15.0
export var speed_max : float = 25.0
export var ground_friction : float = 12.0
export var air_friction : float = 1.5
export var jump_force : float = 25.0
export var gravity : float = 60.0
export var air_control_factor : float = 0.1
export var mouse_sens : float = 0.1
export var ignore_rotation : bool = false
export var health_max = 100;

onready var camera : Camera = $Camera


func _init() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	health_node = BaseResource.new(health_max, health_max);
	health_node.name = "HealthPoints"
	add_child(health_node);


func _input(event: InputEvent) -> void:
	_rotate_camera(event)
	if event.is_action_pressed("jump"):
		_apply_jump()


func _process(delta: float) -> void:
	_calculate_move_direction()


func _physics_process(delta: float) -> void:
	_move_direction = _move_direction.rotated(Vector3.UP, rotation.y)
	_calculate_horizontal_velocity(_move_direction)
	_apply_gravity()
	var velocity = _velocity_horizontal + _velocity_vertical
	move_and_slide(velocity, Vector3.UP)


func _rotate_camera(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera.rotation_degrees.x -= mouse_sens * event.get_relative().y
		rotation_degrees.y -= mouse_sens * event.get_relative().x
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, CAM_ROT_MIN, CAM_ROT_MAX)


func _calculate_move_direction() -> void:
	_move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	_move_direction.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	_move_direction = _move_direction.normalized()


func _calculate_horizontal_velocity(direction: Vector3) -> void:
	var velocity_factor : float
	
	if direction != Vector3.ZERO:
		velocity_factor = acceleration if is_on_floor() else acceleration * air_control_factor
	else:
		velocity_factor = ground_friction if is_on_floor() else air_friction * air_control_factor
	
	_velocity_horizontal = _velocity_horizontal.linear_interpolate(direction * speed_max, velocity_factor * get_physics_process_delta_time())


func _apply_gravity() -> void:
	if is_on_floor():
		return
	
	_velocity_vertical.y -= gravity * get_physics_process_delta_time()


func _apply_jump() -> void:
	if is_on_floor() :
		_velocity_vertical.y = jump_force
