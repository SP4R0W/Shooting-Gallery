extends Node2D

@onready var label: Label = $KillLabel

func _ready():
	$KillLabel/AnimationPlayer.play("Show")
	label.rotation_degrees = randf_range(-7.5,7.5)

func set_score_text(value: int):
	label.text = "+" + str(value)

func _on_animation_player_animation_finished(anim_name):
	queue_free()
