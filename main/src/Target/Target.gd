class_name Target
extends Node2D

signal targeted(enemy: Target)
signal not_targeted(enemy: Target)
signal killed(enemy: Target)

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

var _is_dead: bool = false

func _ready():
	Globals.game.total_spawned += 1
	set_physics_process(!is_static)

	targeted.connect(Globals.game._on_enemy_targeted)
	not_targeted.connect(Globals.game._on_enemy_not_targeted)

	_on_ready()

func _on_ready():
	pass

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	Globals.active_script.enemy_killed()
	queue_free()

func _on_hitbox_mouse_entered():
	targeted.emit(self)

func _on_hitbox_mouse_exited():
	not_targeted.emit(self)

func show_score_text():
	var label = label_scene.instantiate()
	Globals.game.add_child(label)
	label.global_position = global_position

	var score_text = kill_score * Globals.game.combo if Globals.game.combo > 1 else kill_score

	label.set_score_text(score_text)

func animator():
	pass

func enemy_gone():
	pass

func kill():
	if not _is_dead:
		killed.emit(self)
		show_score_text()

		_is_dead = true

		queue_free()


func _on_gone_timer_timeout():
	enemy_gone()
