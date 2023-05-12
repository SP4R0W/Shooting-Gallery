extends ParallaxBackground

@onready var parallax_layer: ParallaxLayer = $ParallaxLayer

@export var speed: Vector2 = Vector2(0,-2.5)

func _process(delta):
	parallax_layer.motion_offset += speed
