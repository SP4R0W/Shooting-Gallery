extends GameScript

@onready var spawn_timer: Timer = $SpawnTimer
@onready var spawn_zone: Node = null

var target_spawn_points: Dictionary = {

}

func _on_activate():
	if not Globals.game:
		await get_tree().process_frame

	spawn_zone = Globals.game.get_node("Background/SpawnZone")

	for point in $Positions.get_children():
		target_spawn_points[point] = null

	spawn_timer.start()

func _deactivate_timers():
	spawn_timer.stop()

func _select_type(target: GameTarget):
	if total_enemies % 15 == 0:
		target.set_type(5)
		target.static_duration = 0.75
	elif total_enemies % 10 == 0:
		target.set_type(4)
		target.static_duration = 1
	else:
		target.set_type(randi_range(1,3))
		target.static_duration = 2

func _spawn_target():
	var position
	var point

	while true:
		position = randi_range(0,target_spawn_points.size()-1)
		point = target_spawn_points[target_spawn_points.keys()[position]]
		if point == null:
			break

	var target = _create_enemy()

	if point != null:
		target.queue_free()
		return

	target_spawn_points[target_spawn_points.keys()[position]] = target
	spawn_zone.add_child(target)
	target.global_position = target_spawn_points.keys()[position].global_position

	target.killed.connect(clear_pos)
	target.spawn_static_fade()
	_select_type(target)

func clear_pos(target: Target):
	var key = target_spawn_points.find_key(target)
	if key != null:
		target_spawn_points[key] = null
		return

func _on_spawn_timer_timeout():
	_spawn_target()
