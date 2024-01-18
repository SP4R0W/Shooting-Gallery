extends Node2D

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var bg = $Background

@onready var is_transitioning = true

@onready var rank_text: Label = $CanvasLayer/Control/VBoxContainer/Data/Rank/Rank2
@onready var score_text: Label = $CanvasLayer/Control/VBoxContainer/Data/Score

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_custom_mouse_cursor(null,Input.CURSOR_ARROW,Vector2(0,0))
	bg.play_animation = false

	$CanvasLayer/Control/VBoxContainer/Data/Level.text = "You played: " + Globals.end_level
	$CanvasLayer/Control/VBoxContainer/Data/Shot.text = "You shot: " + str(Globals.end_shot) + " enemies"
	$CanvasLayer/Control/VBoxContainer/Data/Time.text = "Your time: " + str(Globals.end_time)

	if Globals.ta_game:
		score_text.hide()
	else:
		score_text.show()

	score_text.text = "Your total score: " + str(Globals.end_score)

	_check_score()

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

	$MenuTheme.play()

	is_transitioning = false
	bg.play_animation = true

func _unhandled_input(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.is_pressed() \
	and animator.is_playing():
		$MenuTheme.play()
		animator.seek(2)
		animator.animation_finished.emit()

func _check_score():
	if !Globals.ta_game:
		var score = SaveData.stats[Globals.level_id + "_hi"]
		if Globals.end_score > score:
			$CanvasLayer/Control/VBoxContainer/Data/HI.text = "You set a new high score!"
			SaveData.stats[Globals.level_id + "_hi"] = Globals.end_score
		else:
			$CanvasLayer/Control/VBoxContainer/Data/HI.text = "You didn't set a new high score : ("

		SaveData.stats[Globals.level_id + "_rank"] = Globals.end_rank

		var money = int(Globals.end_score / 250)
		SaveData.stats["money"] += money
		$CanvasLayer/Control/VBoxContainer/Data/Money.text = "You earned " + str(money) + " coins"
	else:
		var time = SaveData.stats[Globals.level_id + "_ta_hi"]
		if Globals.end_time > time:
			$CanvasLayer/Control/VBoxContainer/Data/HI.text = "You set a new fast time!"
			SaveData.stats[Globals.level_id + "_ta_hi"] = Globals.end_time
		else:
			$CanvasLayer/Control/VBoxContainer/Data/HI.text = "You didn't set a new fast time : ("

		SaveData.stats[Globals.level_id + "_ta_rank"] = Globals.end_rank

		var money = int(Globals.end_shot * 1.25)
		SaveData.stats["money"] += money
		$CanvasLayer/Control/VBoxContainer/Data/Money.text = "You earned " + str(money) + " coins"

	SaveData.save_game()

func _on_menu_button_pressed():
	if is_transitioning:
		return

	Globals.root.get_node("Click").play()

	bg.play_animation = false
	is_transitioning = true

	animator.play("CurtainDown")

	await animator.animation_finished

	Globals.root.change_scene("GameOver","LevelSelect")
