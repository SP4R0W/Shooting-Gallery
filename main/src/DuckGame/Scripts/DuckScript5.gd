extends GameScript

@onready var spawn_timer: Timer = $Spawn
@onready var spawn_down_timer: Timer = $SpawnDown

@onready var left_timer: Timer = $Left
@onready var right_timer: Timer = $Right

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
	left_timer.start()
	right_timer.start()

func _deactivate_timers():
	spawn_timer.stop()
	spawn_down_timer.stop()
	left_timer.stop()
	right_timer.stop()

func _select_type(duck: Duck):
	if total_enemies % 15 == 0:
		duck.set_type(3)
		duck.static_duration = 1
		duck.speed = 1250
	elif total_enemies % 5 == 0:
		duck.set_type(2)
		duck.static_duration = 2
		duck.speed = 1000
	else:
		duck.set_type(1)
		duck.static_duration = 3
		duck.speed = 750

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

	if point != null:
		duck.queue_free()
		_spawn_duck()

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

func _spawn_duck_left():
	var duck = _create_enemy()
	duck.show()
	_select_type(duck)

	duck_spawn_zone_1.add_child(duck)
	duck.global_position = Vector2(135,1235)

func _spawn_duck_right():
	var duck = _create_enemy()
	duck.show()
	_select_type(duck)

	duck_spawn_zone_2.add_child(duck)
	duck.direction = Vector2(-1,0)
	duck.global_position = Vector2(3700,1375)

func _on_left_timeout():
	_spawn_duck_left()


func _on_right_timeout():
	_spawn_duck_right()
