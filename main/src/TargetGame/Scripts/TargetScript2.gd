extends GameScript

@onready var spawn_timer: Timer = $SpawnTimer
@onready var spawn_zone: Node = null

var _current_position: int = -1
var target_spawn_points: Array = []

func _on_activate():
	if not Globals.game:
		await get_tree().process_frame

	spawn_zone = Globals.game.get_node("Background/SpawnZone")

	for position in $Positions.get_children():
		target_spawn_points.append(position)

	spawn_timer.start()

func _deactivate_timers():
	spawn_timer.stop()

func _select_type(target: GameTarget):
	if total_enemies % 10 == 0:
		target.set_type(5)
		target.static_duration = 1
	elif total_enemies % 7 == 0:
		target.set_type(4)
		target.static_duration = 1.25
	else:
		target.set_type(randi_range(1,3))
		target.static_duration = 2

func _spawn_target():
	var target = _create_enemy()
	target.spawn_static()
	_select_type(target)

	spawn_zone.add_child(target)

	target.global_position = target_spawn_points[_current_position].global_position

func _on_spawn_timer_timeout():
	_current_position += 1

	if _current_position == target_spawn_points.size():
		_deactivate_timers()
		return

	_spawn_target()
