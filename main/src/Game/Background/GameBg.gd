extends ParallaxBackground

@export var speed_water1: Vector2 = Vector2(0,-2.5)
@export var speed_water2: Vector2 = Vector2(0,-1.5)

@onready var water_layer_1: ParallaxLayer = $Water1
@onready var water_layer_2: ParallaxLayer = $Water2

func _process(delta):
	water_layer_1.motion_offset += speed_water1
	water_layer_2.motion_offset += speed_water2
