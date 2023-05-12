extends Node2D

func _on_play_button_pressed():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	Composer.goto_scene("res://src/DuckGame/DuckGame.tscn",{"is_animated":true,"animation":1})
