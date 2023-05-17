extends ParallaxBackground

@export var speed_water1: Vector2 = Vector2(0,-2.5)
@export var speed_water2: Vector2 = Vector2(0,-1.5)

@export var speed_clouds: Vector2 = Vector2(-1.5,0)

@onready var clouds: ParallaxLayer = $Clouds
@onready var water_layer_1: ParallaxLayer = $Water1
@onready var water_layer_2: ParallaxLayer = $Water2

var play_animation: bool = true:
	set(val):
		play_animation = val
		set_process(play_animation)

func _process(delta):
	clouds.motion_offset += speed_clouds
	water_layer_1.motion_offset += speed_water1
	water_layer_2.motion_offset += speed_water2
