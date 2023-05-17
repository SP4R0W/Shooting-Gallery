extends Node2D

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var bg = $Background

@onready var is_transitioning = true

@onready var rank_text: Label = $CanvasLayer/Control/VBoxContainer/Data/Rank/Rank2

func _ready():
	bg.play_animation = false

	$CanvasLayer/Control/VBoxContainer/Data/Level.text = "You played: " + Globals.end_level
	$CanvasLayer/Control/VBoxContainer/Data/Shot.text = "You shot: " + str(Globals.end_shot) + " enemies"
	$CanvasLayer/Control/VBoxContainer/Data/Time.text = "Your time: " + str(Globals.end_time)
	$CanvasLayer/Control/VBoxContainer/Data/Score.text = "Your total score: " + str(Globals.end_score)
	$CanvasLayer/Control/VBoxContainer/Data/HI.text = "You didn't set a new high score : ("

	rank_text.text = Globals.end_rank
	match Globals.end_rank:
		"NONE":
			rank_text.add_theme_color_override("font_outline_color",Color.BLACK)
		"BRONZE":
			rank_text.add_theme_color_override("font_outline_color",Color.SADDLE_BROWN)
		"SILVER":
			rank_text.add_theme_color_override("font_outline_color",Color.SILVER)
		"GOLD":
			rank_text.add_theme_color_override("font_outline_color",Color.GOLDENROD)
		"PLATINUM":
			rank_text.add_theme_color_override("font_outline_color",Color.SKY_BLUE)

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

func _on_menu_button_pressed():
	if is_transitioning:
		return

	bg.play_animation = false
	is_transitioning = true

	animator.play("CurtainDown")

	await animator.animation_finished

	Composer.goto_scene("res://src/MainMenu/MainMenu.tscn",{"is_animated":true,"animation":1})
