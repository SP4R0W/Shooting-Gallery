class_name GameScript
extends Node

signal script_activated()
signal script_ended()

@export var enemy: PackedScene

@onready var duration_timer: Timer = $Duration

var _enemies: int = 0
var total_enemies: int = 0

func pause():
	for child in get_children():
		if child is Timer:
			child.paused = true

func unpause():
	for child in get_children():
		if child is Timer:
			child.paused = false

func activate():
	Globals.active_script = self

	duration_timer.start()

	script_activated.emit()

	_on_activate()

func _on_activate():
	pass

func deactive():
	script_ended.emit()

	_on_deactivate()

func _on_deactivate():
	pass

func _deactivate_timers():
	pass

func _create_enemy() -> Target:
	total_enemies += 1
	_enemies += 1
	return enemy.instantiate() if enemy else null

func enemy_killed():
	_enemies -= 1
	if _enemies == 0 and duration_timer.time_left <= 0:
		deactive()

func _on_duration_timeout():
	_deactivate_timers()

	if _enemies == 0:
		deactive()
