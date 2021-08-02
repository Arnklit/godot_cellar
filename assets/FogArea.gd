extends Area

export var fade_length := 1.0
export var environment_path : NodePath
export var moonlit_fog_height = -6.0
export var corridor_fog_height = -12.0

onready var _tween := $Tween
onready var _environment : WorldEnvironment = get_node(environment_path)


func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")


func _on_body_entered(body : Node) -> void:
	if body is KinematicBody:
		_tween.stop_all()
		_tween.interpolate_property(_environment.environment, "fog_height_max", _environment.environment.fog_height_max, moonlit_fog_height, fade_length, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		_tween.start()


func _on_body_exited(body : Node) -> void:
	if body is KinematicBody:
		_tween.stop_all()
		_tween.interpolate_property(_environment.environment, "fog_height_max", _environment.environment.fog_height_max, corridor_fog_height, fade_length, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		_tween.start()


func _exit_tree() -> void:
	disconnect("body_entered", self, "_on_body_entered")
	disconnect("body_exited", self, "_on_body_exited")
