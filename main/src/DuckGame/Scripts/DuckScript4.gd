extends GameScript

@onready var spawn_timer: Timer = $Spawn
@onready var spawn_down_timer: Timer = $SpawnDown

var duck_spawn_zone_1: Node2D = null
var duck_spawn_zone_2: Node2D = null

var duck_spawn_points_1: Dictionary = {

}

var duck_spawn_points_2: Dictionary = {

}

func _on_activate():
	if not Globals.game:
		await get_tree().process_frame

	duck_spawn_zone_1 = Globals.game.get_node("Background/DuckZone1")
	duck_spawn_zone_2 = Globals.game.get_node("Background/DuckZone2")

	for point in $PositionsUp.get_children():
		duck_spawn_points_1[point] = null

	for point in $PositionsDown.get_children():
		duck_spawn_points_2[point] = null

	spawn_timer.start()
	spawn_down_timer.start()

func _deactivate_timers():
	spawn_timer.stop()
	spawn_down_timer.stop()

func _select_type(duck: Duck):
	if total_enemies % 10 == 0:
		duck.set_type(3)
		duck.static_duration = 1
	elif total_enemies % 5 == 0:
		duck.set_type(2)
		duck.static_duration = 2
	else:
		duck.set_type(1)
		duck.static_duration = 3

func _spawn_duck():
	var position
	var point

	while true:
		position = randi_range(0,duck_spawn_points_1.size()-1)
		point = duck_spawn_points_1[duck_spawn_points_1.keys()[position]]
		if point == null:
			break

	var duck = _create_enemy()
	duck.is_static = true
	duck.static_duration = 3

	if point != null:
		duck.queue_free()
		return

	duck_spawn_points_1[duck_spawn_points_1.keys()[position]] = duck
	duck_spawn_zone_1.add_child(duck)
	duck.global_position = duck_spawn_points_1.keys()[position].global_position

	_select_type(duck)
	duck.spawn_static()
	duck.killed.connect(clear_pos)

func _spawn_duck_down():
	var position
	var point

	while true:
		position = randi_range(0,duck_spawn_points_2.size()-1)
		point = duck_spawn_points_2[duck_spawn_points_2.keys()[position]]
		if point == null:
			break

	var duck = _create_enemy()
	duck.is_static = true

	if point != null:
		duck.queue_free()
		_spawn_duck_down()

	duck_spawn_points_2[duck_spawn_points_2.keys()[position]] = duck
	duck_spawn_zone_2.add_child(duck)
	duck.global_position = duck_spawn_points_2.keys()[position].global_position

	_select_type(duck)
	duck.spawn_static()
	duck.killed.connect(clear_pos)

func clear_pos(target: Target):
	var key1 = duck_spawn_points_1.find_key(target)
	if key1 != null:
		duck_spawn_points_1[key1] = null
		return

	var key2 = duck_spawn_points_2.find_key(target)
	if key2 != null:
		duck_spawn_points_2[key2] = null

func _on_spawn_timeout():
	_spawn_duck()

func _on_spawn_down_timeout():
	_spawn_duck_down()
