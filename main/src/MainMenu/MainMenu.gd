extends Node2D

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var bg = $Background

@onready var is_transitioning = true
@onready var menu_theme: AudioStreamPlayer = Globals.root.get_node("MenuTheme")

func _ready():
	if OS.get_name() == "Web":
		$CanvasLayer/Control/VBoxContainer/ExitButton.hide()

	bg.play_animation = false

	animator.play("CurtainUp")

	await animator.animation_finished

	if not menu_theme.playing:
		menu_theme.play()

	is_transitioning = false
	bg.play_animation = true

func _unhandled_input(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.is_pressed() \
	and animator.is_playing():
		animator.seek(2)
		animator.animation_finished.emit()

		if not menu_theme.playing:
			menu_theme.play()

func _on_play_button_pressed():
	if is_transitioning:
		return

	Globals.root.get_node("Click").play()

	bg.play_animation = false
	is_transitioning = true

	animator.play("CurtainDown")

	await animator.animation_finished

	Globals.root.change_scene("MainMenu","LevelSelect")

func _on_options_button_pressed():
	if is_transitioning:
		return

	Globals.root.get_node("Click").play()

	bg.play_animation = false
	is_transitioning = true

	animator.play("CurtainDown")

	await animator.animation_finished

	Globals.root.change_scene("MainMenu","Options")

func _on_credits_button_pressed():
	if is_transitioning:
		return

	Globals.root.get_node("Click").play()

	bg.play_animation = false
	is_transitioning = true

	animator.play("CurtainDown")

	await animator.animation_finished

	Globals.root.change_scene("MainMenu","Credits")

func _on_exit_button_pressed():
	if is_transitioning:
		return

	get_tree().quit()
