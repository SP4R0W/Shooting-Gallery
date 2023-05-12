class_name Weapon
extends AnimatedSprite2D

@export var weight: float = 0.5
@onready var width = ProjectSettings.get_setting("display/window/size/viewport_width")
@onready var height = ProjectSettings.get_setting("display/window/size/viewport_height")

func _physics_process(delta):
	global_position = Vector2(
		lerp(global_position.x,clamp(get_global_mouse_position().x,width * 0.085,width * 0.9),weight),
		lerp(global_position.y,clamp(get_global_mouse_position().y,height * 0.5,height * 0.9),weight)
	)

func show_ready():
	animation = "default"

func show_empty():
	animation = "empty"
