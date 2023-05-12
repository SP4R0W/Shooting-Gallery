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

@onready var ui: GameUI = $CanvasLayer/UI
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var weapon: Weapon = $CanvasLayer/UI/Weapon

@onready var firerate_timer: Timer = $Firerate
@onready var reload_timer: Timer = $Reload

@onready var normal_cursor: Resource = preload("res://assets/HUD/crosshair_white_small.png")
@onready var wait_cursor: Resource = preload("res://assets/HUD/sand-clock.png")

const MAX_BULLETS: int = 3

var _game_started: bool = false
var _score: int = 0
var _time: int = 0
var _rank: String = "none"

var _target: Target = null

var _script: int = -1

var bullets: int = MAX_BULLETS:
	set(val):
		bullets = val
		bullets_changed.emit(bullets)

func _ready():
	Globals.game = self

	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_init_game_scripts()

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

				_check_for_target()
			else:
				if reload_timer.time_left <= 0:
					_start_reload()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
			if reload_timer.time_left <= 0 and bullets < MAX_BULLETS:
				_start_reload()

func _on_ready():
	pass

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
		print("Game over")

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

	$CanvasLayer/UI/BottomUI/Text/Rank.text = "Rank: " + _rank.to_upper()

func _check_for_target():
	if _target:
		Globals.active_script.enemy_killed()
		_score += _target.kill_score
		_check_for_rank()
		score_updated.emit(_score)

		_target.kill()

func _start_reload():
	Input.set_custom_mouse_cursor(wait_cursor,Input.CURSOR_ARROW,Vector2(21,21))

	$Sounds/Reload.play()
	weapon.show_empty()
	reload_timer.start()

func _end_reload():
	Input.set_custom_mouse_cursor(normal_cursor,Input.CURSOR_ARROW,Vector2(21,21))

	weapon.show_ready()
	bullets = MAX_BULLETS

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
