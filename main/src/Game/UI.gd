class_name GameUI
extends Control

@onready var ui_panel: HSplitContainer = $BottomUI

@onready var level_title: Label = $BottomUI/Text/Title
@onready var score_text: Label = $BottomUI/Text/Score
@onready var time_text: Label = $BottomUI/Text/Time
@onready var ammo_counter: HBoxContainer = $BottomUI/AmmoCounter

@onready var bullet_img: Texture2D = preload("res://assets/HUD/icon_bullet_gold_long.png")
@onready var empty_img: Texture2D = preload("res://assets/HUD/icon_bullet_empty_long.png")

func _ready():
	await get_tree().process_frame

	Globals.game.connect("bullets_changed",_update_bullets)
	Globals.game.connect("score_updated",_update_score)
	Globals.game.connect("time_updated",_update_time)
	ui_panel.hide()

func show_ui():
	ui_panel.show()

func _update_score(score: int):
	score_text.text = "Score: " + str(score)

func _update_bullets(bullet_amount: int):
	for x in range(ammo_counter.get_child_count()-1,-1,-1):
		var bullet: TextureRect = ammo_counter.get_child(x)
		if bullet_amount > x:
			bullet.texture = bullet_img
		else:
			bullet.texture = empty_img

func _update_time(time: int):
	time_text.text = "Time: " + str(time)
	_update_game_time()

func _update_game_time():
	pass
