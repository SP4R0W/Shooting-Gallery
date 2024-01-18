class_name Target
extends Node2D

signal killed(target: Target)

@export var kill_score: int = 100
@export var direction: Vector2 = Vector2(1,0)
@export var speed: float = 500

@export var is_static: bool = false:
	set(val):
		is_static = val
		set_physics_process(!is_static)

@export var static_duration: float = 1.0:
	set(val):
		static_duration = val
		$GoneTimer.wait_time = static_duration

@onready var label_scene = preload("res://src/Target/KillLabel.tscn")

var _is_mouse_inside: bool = false
var _is_dead: bool = false
var _is_paused: bool = false
var _has_paused_animation: bool = false

func _ready():
	if Globals.game != null:
		Globals.game.total_spawned += 1
		killed.connect(Globals.game._on_enemy_killed)

	set_physics_process(!is_static)
	set_process_unhandled_input(false)

	_on_ready()

func _on_ready():
	pass

func _physics_process(delta):
	global_position += direction * speed * delta

func _unhandled_input(event):
	if not Globals.game.can_shoot || _is_paused:
		return

	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed() && _is_mouse_inside:
		kill()

func _on_visible_on_screen_notifier_2d_screen_exited():
	Globals.active_script.enemy_killed()
	queue_free()

func _on_hitbox_mouse_entered():
	if _is_paused:
		_is_mouse_inside = false
		set_process_unhandled_input(false)
		return

	_is_mouse_inside = true
	set_process_unhandled_input(true)

func _on_hitbox_mouse_exited():
	_is_mouse_inside = false
	set_process_unhandled_input(false)

func show_score_text():
	var label = label_scene.instantiate()
	Globals.game.add_child(label)
	label.global_position = global_position

	var score_text = kill_score * Globals.game.combo if Globals.game.combo > 1 else kill_score

	label.set_score_text(score_text)

func enemy_gone():
	pass

func kill(quiet_kill: bool = false):
	if not _is_dead:
		killed.emit(self)
		if not quiet_kill: show_score_text()

		_is_dead = true

		queue_free()


func _on_gone_timer_timeout():
	enemy_gone()

func pause():
	_is_paused = true
	_has_paused_animation = false

	set_physics_process(false)
	set_process_unhandled_input(false)

	$GoneTimer.paused = true

	var anim: AnimationPlayer = get_node("AnimationPlayer")
	if anim.is_playing():
		_has_paused_animation = true
		anim.pause()

func unpause():
	_is_paused = false

	set_physics_process(!is_static)
	set_process_unhandled_input(true)

	$GoneTimer.paused = false

	if _has_paused_animation:
		get_node("AnimationPlayer").play()
