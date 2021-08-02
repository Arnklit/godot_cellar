extends KinematicBody

export var mouse_sensitivity := 0.25

export var movement_speed := 3.0
export var acceleration := 4.0

export var rotation_speed := 1.0
export var tilt_speed := 1.0

export(float, -90, 0.0) var tilt_upper_limit := -60.0
export(float, 0.0, 90.0) var tilt_lower_limit := 60.0

export(float, EASE) var sensitivity_curve := -2.0

var _rot_input : float
var _tilt_input : float
var _mouse_input := false
var _velocity : Vector3
var _y_velocity: float

onready var  _tilt_pivot = $TiltPivot
onready var _gravity : float = -ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event.is_action_pressed("capture_mouse"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	_mouse_input = false
	if event is InputEventMouseMotion:
		_mouse_input = true
		_rot_input = -event.relative.x * mouse_sensitivity
		_tilt_input = -event.relative.y * mouse_sensitivity


func _physics_process(delta: float) -> void:
	_rot_input += Input.get_action_strength("camera_left") - Input.get_action_strength("camera_right")
	_tilt_input += Input.get_action_strength("camera_up") - Input.get_action_strength("camera_down")
	if not _mouse_input:
		# If the input is from joystick, we run it through an S-curve. The ease function only takes positive
		# numbers, so if it's a negative number we invert it before and after.
		_rot_input = ease(_rot_input, sensitivity_curve) if _rot_input > 0 else -ease(-_rot_input, sensitivity_curve)
		_tilt_input = ease(_tilt_input, sensitivity_curve) if _tilt_input > 0 else -ease(-_tilt_input, sensitivity_curve)
	
	rotate_y(_rot_input * rotation_speed * delta)
	_tilt_pivot.rotate_x(_tilt_input * tilt_speed * delta)
	_tilt_pivot.rotation_degrees.x = clamp(_tilt_pivot.rotation_degrees.x, tilt_upper_limit, tilt_lower_limit)
	
	var input_rl := Input.get_action_strength("player_right") - Input.get_action_strength("player_left")
	var input_bf := Input.get_action_strength("player_back") - Input.get_action_strength("player_forward")
	var raw_input := Vector2(input_rl, input_bf)
	#var input = raw_input
	var input := Vector3.ZERO
	input.x = raw_input.x * sqrt(1.0 - raw_input.y * raw_input.y / 2.0)
	input.z = raw_input.y * sqrt(1.0 - raw_input.x * raw_input.x / 2.0)
	
	input = global_transform.basis.xform(input)
	
	_velocity = _velocity.linear_interpolate(input * movement_speed, delta * acceleration)
	
	_y_velocity = _velocity.y
	_velocity.y = 0.0
	
	if is_on_floor():
		_y_velocity = 0.0
	else:
		_y_velocity += _gravity * delta
	
	_velocity.y = _y_velocity
	
	move_and_slide(_velocity, Vector3.UP, true)
	
	
	# zero out input before next frame
	_rot_input = 0.0
	_tilt_input = 0.0
