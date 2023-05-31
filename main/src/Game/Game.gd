class_name Game
extends Node2D

signal bullets_changed(bullet_amount: int)
signal score_updated(score: int)
signal time_updated(time: int)

@export var ta_score: int = 50000
@export var scripts: Array[PackedScene] = []
@export var rank_score: Dictionary = {
	"bronze":500,
	"silver":1000,
	"gold":2000,
	"platinum":5000
}
@export var ta_rank_score: Dictionary = {
	"bronze":240,
	"silver":180,
	"gold":135,
	"platinum":120
}

@onready var bg = $Background
@onready var ui: GameUI = $CanvasLayer/UI
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var weapon: Weapon = $CanvasLayer/UI/Weapon
@onready var combo_text: Label = $CanvasLayer/UI/Combo
@onready var bonus_text: Label = $CanvasLayer/UI/Bonus
@onready var bonus_animator: AnimationPlayer = $CanvasLayer/UI/Bonus/AnimationPlayer

@onready var firerate_timer: Timer = $Firerate
@onready var reload_timer: Timer = $Reload

@onready var normal_cursor: Resource = preload("res://assets/HUD/crosshair_white_small.png")
@onready var wait_cursor: Resource = preload("res://assets/HUD/sand-clock.png")

@onready var combo_timer: Timer = $Combo

var max_bullets: int = 3

var _is_game_started: bool = false
var _is_game_over: bool = false
var can_shoot: bool = false

var _score: int = 0
var _time: int = 0
var combo: int = 0
var _rank: String = "none"

var _script: int = -1

var total_spawned: int = 0
var total_killed: int = 0

var combo_font_size = 72

var is_paused: bool = false

var bullets: int = max_bullets:
	set(val):
		bullets = val
		bullets_changed.emit(bullets)

func _ready():
	if Globals.ta_game:
		_score = ta_score
		_rank = "platinum"
		ui.set_rank(_rank)

	Globals.game = self
	bg.play_animation = false

	$CanvasLayer/UI/BottomUI/Text/Title.text = Globals.end_level

	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_init_game_scripts()

	_init_game_upgrades()

	weapon.hide()
	animator.play("CurtainUp")

	await animator.animation_finished

	$Music/Track.play()

	animator.play("ShowText")

	await animator.animation_finished

	ui.show_ui()
	Input.set_custom_mouse_cursor(normal_cursor,Input.CURSOR_ARROW,Vector2(21,21))
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	weapon.show()

	$Time.start()

	bg.play_animation = true
	_is_game_started = true
	_start_next_script()

	can_shoot = true

	_on_ready()

func _unhandled_input(event):
	if not _is_game_started || _is_game_over:
		return

	if Input.is_action_just_pressed("exit"):
		Globals.root.get_node("Click").play()

		Composer.goto_scene("res://src/LevelSelect/LevelSelect.tscn",{"is_animated":true,"animation":1})
	elif Input.is_action_just_pressed("reset"):
		Composer.goto_scene(Globals.LEVEL_PATHS[Globals.level_id],{"is_animated":true,"animation":1})
	elif Input.is_action_just_pressed("pause"):
		Globals.root.get_node("Click").play()
		_pause_game()

	if event is InputEventMouseButton && not is_paused:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if bullets > 0 && can_shoot:
				$Sounds/Fire.play()
				bullets -= 1
				firerate_timer.start() if bullets > 0 else null;
				can_shoot = false

				if bullets == 0 and SaveData.settings["auto_reload"]:
					_start_reload()
			elif bullets <= 0:
				if reload_timer.time_left <= 0:
					_start_reload()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
			if reload_timer.time_left <= 0 and bullets < max_bullets:
				_start_reload()

func _on_ready():
	pass

func _on_enemy_killed(target: Target):
	total_killed += 1
	Globals.active_script.enemy_killed()

	if !Globals.ta_game:
		_check_for_rank()

	score_updated.emit(_score)
	update_combo()
	_check_for_bonus()

	var _score_update = target.kill_score * combo if combo > 1 else target.kill_score

	if !Globals.ta_game:
		_score += _score_update
	else:
		_score -= _score_update
		if _score <= 0 and Globals.ta_game:
			_game_over()

	ui.score_to_update += _score_update

func _pause_game():
	is_paused = !is_paused

	if is_paused:
		if Globals.active_script != null:
			Globals.active_script.pause()

		weapon.set_physics_process(false)

		firerate_timer.paused = true
		reload_timer.paused = true
		$Time.paused = true
		combo_timer.paused = true

		$Music/Track.stream_paused = true

		get_tree().call_group("target","pause")

		$CanvasLayer/UI/Pause/AnimationPlayer.play("Show")
	else:
		if Globals.active_script != null:
			Globals.active_script.unpause()

		weapon.set_physics_process(true)

		firerate_timer.paused = false
		reload_timer.paused = false
		$Time.paused = false
		combo_timer.paused = false

		$Music/Track.stream_paused = false

		get_tree().call_group("target","unpause")

		$CanvasLayer/UI/Pause/AnimationPlayer.stop()
		$CanvasLayer/UI/Pause.hide()

func _game_over():
	if _is_game_over:
		return

	can_shoot = false

	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	bg.play_animation = false

	$Time.stop()
	_is_game_over = true

	if total_killed == total_spawned:
		_score += 50000
		ui.score_to_update += 50000

	weapon.hide()
	animator.play("CurtainDown")

	await animator.animation_finished

	Globals.end_rank = _rank.to_upper()
	Globals.end_time = _time
	Globals.end_score = _score
	Globals.end_level = "Duck Hunt"
	Globals.end_shot = total_killed

	Composer.goto_scene("res://src/GameOver/GameOver.tscn",{"is_animated":true,"animation":1})

func _init_game_upgrades():
	var mag_update = SaveData.stats["upgrade_mag"]
	var reload_update = SaveData.stats["upgrade_reload"]
	var fire_update = SaveData.stats["upgrade_firerate"]

	match reload_update:
		0:
			reload_timer.wait_time = 1.15
		1:
			reload_timer.wait_time = 1
		2:
			reload_timer.wait_time = 0.85
		3:
			reload_timer.wait_time = 0.65

	match fire_update:
		0:
			firerate_timer.wait_time = 0.75
		1:
			reload_timer.wait_time = 0.65
		2:
			reload_timer.wait_time = 0.55
		3:
			reload_timer.wait_time = 0.35

	var bullets_total = 3 + 1 * mag_update
	max_bullets = bullets_total
	bullets = bullets_total

func _init_game_scripts():
	for script in scripts:
		var game_script = script.instantiate()
		game_script.script_ended.connect(_on_script_ended)
		$Scripts.add_child(game_script)

func _start_next_script():
	_script += 1

	var scripts_root: Node = $Scripts

	if scripts_root.get_child_count() > _script:
		var script: GameScript = $Scripts.get_child(_script)
		script.activate()
	else:
		if Globals.ta_game:
			_script = -1
			_start_next_script()
			return

		_game_over()

func _check_for_rank():
	if _rank == "platinum":
		return

	if _score >= rank_score["platinum"]:
		_rank = "platinum"
	elif _score >= rank_score["gold"]:
		_rank = "gold"
	elif _score >= rank_score["silver"]:
		_rank = "silver"
	elif _score >= rank_score["bronze"]:
		_rank = "bronze"
	else:
		_rank = "none"

	ui.set_rank(_rank)

func _check_for_ta_rank():
	if _time <= ta_rank_score["platinum"]:
		_rank = "platinum"
	elif _time <= ta_rank_score["gold"]:
		_rank = "gold"
	elif _time <= ta_rank_score["silver"]:
		_rank = "silver"
	elif _time <= ta_rank_score["bronze"]:
		_rank = "bronze"
	else:
		_rank = "none"

	ui.set_rank(_rank)

func update_combo(amount: int = 1):
	combo += amount

	if amount > 0:
		combo_timer.start()
	else:
		combo_timer.stop()

	var anim_player: AnimationPlayer = combo_text.get_node("AnimationPlayer")

	if combo > 1:
		combo_text.show()
		anim_player.play("Combo")
	else:
		if combo_text.visible:
			anim_player.stop()
			anim_player.play("Fade_out")

			await anim_player.animation_finished

			combo_font_size = 72
			combo_text.add_theme_font_size_override("font_size",combo_font_size)
			combo_text.add_theme_constant_override("outline_size",int(combo_font_size / 2))
			return
		else:
			combo_text.hide()

	combo_text.text = "Combo x" + str(combo)
	combo_font_size = clamp(combo_font_size+4,72,192)

	combo_text.add_theme_font_size_override("font_size",combo_font_size)
	combo_text.add_theme_constant_override("outline_size",int(combo_font_size / 2))

func _check_for_bonus():
	if total_killed % 100 == 0:
		if total_killed % 50 == 0:
			bonus_text.text = "100 ENEMIES SHOT BONUS +25000 POINTS"
			bonus_animator.play("Show")

			if Globals.ta_game:
				_score -= 25000
			else:
				_score += 25000

			ui.score_to_update += 25000
	elif total_killed % 50 == 0:
		bonus_text.text = "50 ENEMIES SHOT BONUS +10000 POINTS"
		bonus_animator.play("Show")

		if Globals.ta_game:
			_score -= +10000
		else:
			_score += +10000

		ui.score_to_update += 10000

	if _score <= 0 and Globals.ta_game:
		_game_over()

func _start_reload():
	can_shoot = false

	Input.set_custom_mouse_cursor(wait_cursor,Input.CURSOR_ARROW,Vector2(21,21))

	$Sounds/Reload.play()
	weapon.show_empty()
	reload_timer.start()

func _end_reload():
	can_shoot = true

	Input.set_custom_mouse_cursor(normal_cursor,Input.CURSOR_ARROW,Vector2(21,21))

	weapon.show_ready()
	bullets = max_bullets

func _on_reload_timeout():
	_end_reload()

func _on_firerate_timeout():
	if reload_timer.time_left <= 0:
		can_shoot = true

func _on_time_timeout():
	_time += 1
	time_updated.emit(_time)

	if Globals.ta_game:
		_check_for_ta_rank()

func _on_script_ended():
	await get_tree().create_timer(0.5).timeout

	_start_next_script()

func _on_combo_timeout():
	update_combo(-combo)

func _exit_tree():
	Globals.game = null
	Globals.active_script = null

