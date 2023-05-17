extends Node2D

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var bg = $Background

@onready var is_transitioning = true

func _ready():
	bg.play_animation = false

	animator.play("CurtainUp")

	await animator.animation_finished

	is_transitioning = false
	bg.play_animation = true

func _unhandled_input(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.is_pressed() \
	and animator.is_playing():
		animator.seek(2)
		animator.animation_finished.emit()

func _on_play_button_pressed():
	if is_transitioning:
		return

	bg.play_animation = false
	is_transitioning = true

	animator.play("CurtainDown")

	await animator.animation_finished

	Composer.goto_scene("res://src/LevelSelect/LevelSelect.tscn",{"is_animated":true,"animation":1})

func _on_options_button_pressed():
	if is_transitioning:
		return

	bg.play_animation = false
	is_transitioning = true

	animator.play("CurtainDown")

	await animator.animation_finished

	Composer.goto_scene("res://src/Options/Options.tscn",{"is_animated":true,"animation":1})

func _on_credits_button_pressed():
	if is_transitioning:
		return

	bg.play_animation = false
	is_transitioning = true

	animator.play("CurtainDown")

	await animator.animation_finished

	Composer.goto_scene("res://src/Credits/Credits.tscn",{"is_animated":true,"animation":1})

func _on_exit_button_pressed():
	if is_transitioning:
		return

	get_tree().quit()
