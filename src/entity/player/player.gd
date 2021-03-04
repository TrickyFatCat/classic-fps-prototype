class_name Player
extends Entity

const CAM_ROT_MIN : float = -90.0
const CAM_ROT_MAX : float = 90.0
const GROUND_CHECK_DISTANCE : float = 0.25
const GROUND_COLLISION_MASK : int = 1

var _move_direction : Vector3 = Vector3.ZERO
var _player_direction : Vector3 = Vector3.ZERO
var _velocity_horizontal : Vector3 = Vector3.ZERO
var _velocity_vertical : Vector3 = Vector3.ZERO
var _is_on_ground : bool = true

var health_node : BaseResource

export var acceleration : float = 15.0
export var speed_max : float = 20.0
export var ground_friction : float = 12.0
export var air_friction : float = 3.0
export var jump_force : float = 20.0
export var gravity : float = 98.0
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
		return
		_apply_jump()


func _process(delta: float) -> void:
	_calculate_move_direction()


func _physics_process(delta: float) -> void:
	var ground_collision : Dictionary = _get_ground_collision()
	_is_on_ground = not ground_collision.empty()
	_move_direction = _move_direction.rotated(Vector3.UP, rotation.y)
	_calculate_horizontal_velocity(_move_direction)
	_calculate_vertical_velocity()
	_apply_jump()
	var velocity = _velocity_horizontal + _velocity_vertical
	move_and_slide(velocity, Vector3.UP, true, 4, 1)
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


func _calculate_horizontal_velocity(direction: Vector3) -> void:
	var velocity_factor : float
	
	if direction != Vector3.ZERO:
		velocity_factor = acceleration if is_on_floor() else acceleration * air_control_factor
	else:
		velocity_factor = ground_friction if is_on_floor() else air_friction * air_control_factor
	
	_velocity_horizontal = _velocity_horizontal.linear_interpolate(direction * speed_max, velocity_factor * get_physics_process_delta_time())


func _calculate_vertical_velocity() -> void:
	if not is_on_floor():
		_velocity_vertical += Vector3.DOWN * gravity * get_physics_process_delta_time()
	elif is_on_floor() and _is_on_ground:
		_velocity_vertical = -get_floor_normal() * gravity
	else:
		_velocity_vertical = -get_floor_normal()


func _apply_jump() -> void:
	if (is_on_floor() or _is_on_ground) and Input.is_action_just_pressed("jump"):
		_velocity_vertical = Vector3.UP * jump_force


func _get_ground_collision() -> Dictionary:
	var space_state = get_world().direct_space_state
	var start_point : Vector3 = global_transform.origin
	var end_point : Vector3 = start_point + Vector3.DOWN * GROUND_CHECK_DISTANCE
	return space_state.intersect_ray(start_point, end_point, [self], GROUND_COLLISION_MASK)
