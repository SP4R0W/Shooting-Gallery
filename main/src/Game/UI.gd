class_name GameUI
extends Control

signal score_update_ended()

@onready var ui_panel: HSplitContainer = $BottomUI

@onready var level_title: Label = $BottomUI/Text/Title
@onready var score_text: Label = $BottomUI/Text/Score
@onready var time_text: Label = $BottomUI/Text/Time
@onready var rank_text: Label = $BottomUI/Text/Rank/Rank2

@onready var ammo_counter: HBoxContainer = $BottomUI/AmmoCounter

@onready var bullet_img: Texture2D = preload("res://assets/HUD/icon_bullet_gold_long.png")
@onready var empty_img: Texture2D = preload("res://assets/HUD/icon_bullet_empty_long.png")

const SMALL_MAX_CLAMP_VALUE: int = 10
const MEDIUM_MAX_CLAMP_VALUE: int = 50
const BIG_MAX_CLAMP_VALUE: int = 100

var score_to_update = 0
var score_text_value = 0

func _ready():
	await get_tree().process_frame

	Globals.game.connect("bullets_changed",_update_bullets)
	Globals.game.connect("time_updated",_update_time)

	if Globals.ta_game:
		score_text_value = Globals.game._score
		_update_score()

	for x in range(Globals.game.max_bullets):
		ammo_counter.get_child(x).show()

	ui_panel.hide()

func _process(delta):
	var update_value = 0

	if score_to_update > 0 and score_to_update <= 500:
		update_value = clamp(score_to_update,1,SMALL_MAX_CLAMP_VALUE)
	elif score_to_update > 500 and score_to_update <= 2500:
		update_value = clamp(score_to_update,1,MEDIUM_MAX_CLAMP_VALUE)
	elif score_to_update > 2500:
		update_value = clamp(score_to_update,1,BIG_MAX_CLAMP_VALUE)

	if update_value > 0:
		score_to_update -= update_value

		if !Globals.ta_game:
			score_text_value += update_value
		else:
			score_text_value -= update_value

		_update_score()

		score_update_ended.emit()

func show_ui():
	ui_panel.show()

func _update_score():
	score_text.text = "Score: " + str(clamp(score_text_value,0,INF))

func _update_bullets(bullet_amount: int):
	for x in range(0,Globals.game.max_bullets):
		var bullet: TextureRect = ammo_counter.get_child(x)
		if x < bullet_amount:
			bullet.texture = bullet_img
		else:
			bullet.texture = empty_img

func _update_time(time: int):
	time_text.text = "Time: " + str(time)

func set_rank(rank: String):
	rank_text.text = rank.to_upper()

	match rank.to_upper():
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
