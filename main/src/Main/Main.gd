extends Node2D

func _ready() -> void:
	randomize()

	Globals.root = self

	Composer.goto_scene("res://src/MainMenu/MainMenu.tscn",{"is_animated":true,"animation":1})
