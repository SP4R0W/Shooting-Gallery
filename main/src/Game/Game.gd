class_name Game
extends Node2D

signal bullets_changed(bullet_amount: int)
signal score_updated(score: int)
signal time_updated(time: int)

@export var ta_time: int = 180
@export var scripts: Array[PackedScene] = []
@export var rank_score: Dictionary = {
	"bronze":500,
	"silver":1000,
	"gold":2000,
	"platinum":5000
}

@onready var bg = $Background
@onready var ui: GameUI = $CanvasLayer/UI
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var weapon: Weapon = $CanvasLayer/UI/Weapon
@onready var combo_text: Label = $CanvasLayer/UI/Combo

@onready var firerate_timer: Timer = $Firerate
@onready var reload_timer: Timer = $Reload

@onready var normal_cursor: Resource = preload("res://assets/HUD/crosshair_white_small.png")
@onready var wait_cursor: Resource = preload("res://assets/HUD/sand-clock.png")

var max_bullets: int = 3

var _game_started: bool = false
var _is_game_over: bool = false

var _score: int = 0
var _time: int = 0
var combo: int = 0
var _rank: String = "none"

var _target: Target = null

var _script: int = -1

var total_spawned: int = 0
var total_killed: int = 0

var bullets: int = max_bullets:
	set(val):
		bullets = val
		bullets_changed.emit(bullets)

func _ready():
	Globals.game = self
	bg.play_animation = false

	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_init_game_scripts()

	_init_game_upgrades()

	weapon.hide()
	animator.play("CurtainUp")

	await animator.animation_finished

	animator.play("ShowText")

	await animator.animation_finished

	ui.show_ui()
	Input.set_custom_mouse_cursor(normal_cursor,Input.CURSOR_ARROW,Vector2(21,21))
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	weapon.show()
	$Time.start()

	bg.play_animation = true
	_game_started = true
	_start_next_script()

	_on_ready()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if firerate_timer.time_left > 0 || not _game_started:
				return

			if bullets > 0:
				$Sounds/Fire.play()
				bullets -= 1
				firerate_timer.start() if bullets > 0 else null;

				if bullets == 0 and SaveData.settings["auto_reload"]:
					_start_reload()

				_check_for_target()
			else:
				if reload_timer.time_left <= 0:
					_start_reload()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
			if reload_timer.time_left <= 0 and bullets < max_bullets:
				_start_reload()

func _on_ready():
	pass

func _game_over():
	if _is_game_over:
		return

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
			reload_timer.wait_time = 1.25
		1:
			reload_timer.wait_time = 1
		2:
			reload_timer.wait_time = 0.85
		3:
			reload_timer.wait_time = 0.65

	match fire_update:
		0:
			firerate_timer.wait_time = 1
		1:
			reload_timer.wait_time = 0.75
		2:
			reload_timer.wait_time = 0.5
		3:
			reload_timer.wait_time = 0.25

	var bullets_total = 3 + 1 * mag_update
	max_bullets = bullets_total
	bullets = bullets_total

func _init_game_scripts():
	for script in scripts:
		var game_script = script.instantiate()
		game_script.script_ended.connect(_on_script_ended)
		$Scripts.add_child(game_script)

func _start_next_script():
	print("Next script")
	_script += 1

	var scripts_root: Node = $Scripts
	print(scripts_root.get_child_count()," ",_script)
	if scripts_root.get_child_count() > _script:
		var script: GameScript = $Scripts.get_child(_script)
		print(script)

		script.activate()
	else:
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

func update_combo(amount: int = 1):
	combo += amount

	if amount > 0:
		$Combo.start()
	else:
		$Combo.stop()

	var anim_player: AnimationPlayer = combo_text.get_node("AnimationPlayer")

	if combo > 1:
		combo_text.show()
		anim_player.play("Combo")
	else:
		if combo_text.visible:
			anim_player.stop()
			anim_player.play("Fade_out")

			await anim_player.animation_finished
		else:
			combo_text.hide()

	combo_text.text = "Combo x" + str(combo)
	combo_text.scale = Vector2(
		clampf(0.5 + combo*0.05,0.5,2),
		clampf(0.5 + combo*0.05,0.5,2)
	)

func _check_for_bonus():
	if total_killed % 50 == 0:
		_score += 5000
		ui.score_to_update += 5000

func _check_for_target():
	if is_instance_valid(_target):
		total_killed += 1
		Globals.active_script.enemy_killed()

		_check_for_rank()
		score_updated.emit(_score)
		update_combo()
		_check_for_bonus()

		var _score_update = _target.kill_score * combo if combo > 1 else _target.kill_score

		_score += _score_update
		ui.score_to_update += _score_update

		_target.kill()

func _start_reload():
	Input.set_custom_mouse_cursor(wait_cursor,Input.CURSOR_ARROW,Vector2(21,21))

	$Sounds/Reload.play()
	weapon.show_empty()
	reload_timer.start()

func _end_reload():
	Input.set_custom_mouse_cursor(normal_cursor,Input.CURSOR_ARROW,Vector2(21,21))

	weapon.show_ready()
	bullets = max_bullets

func _on_reload_timeout():
	_end_reload()

func _on_time_timeout():
	_time += 1
	time_updated.emit(_time)

func _on_enemy_targeted(enemy: Target):
	_target = enemy

func _on_enemy_not_targeted(enemy: Target):
	if _target != null and _target == enemy:
		_target = null

func _on_script_ended():
	await get_tree().create_timer(2).timeout

	_start_next_script()

func _on_combo_timeout():
	update_combo(-combo)

func _exit_tree():
	Globals.game = null
	Globals.active_script = null
