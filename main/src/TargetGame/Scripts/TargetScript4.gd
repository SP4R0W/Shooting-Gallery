extends GameScript

@onready var spawn_timer_left: Timer = $Left
@onready var spawn_timer_right: Timer = $Right
@onready var spawn_timer_up: Timer = $Up

var spawn_zone: Node = null

var target_spawn_points_left: Dictionary = {

}

var target_spawn_points_right: Dictionary = {

}

var target_spawn_points_up: Dictionary = {

}

func _on_activate():
	if not Globals.game:
		await get_tree().process_frame

	spawn_zone = Globals.game.get_node("Background/SpawnZone")

	for point in $PositionsLeft.get_children():
		target_spawn_points_left[point] = null

	for point in $PositionsRight.get_children():
		target_spawn_points_right[point] = null

	for point in $PositionsUp.get_children():
		target_spawn_points_up[point] = null

	spawn_timer_left.start()
	spawn_timer_right.start()
	spawn_timer_up.start()

func _deactivate_timers():
	spawn_timer_left.stop()
	spawn_timer_right.stop()
	spawn_timer_up.stop()

func _select_type(target: GameTarget):
	if total_enemies % 15 == 0:
		target.set_type(5)
		target.speed = 1500
	elif total_enemies % 10 == 0:
		target.set_type(4)
		target.speed = 1000
	else:
		var type = randi_range(1,3)
		target.set_type(type)
		match type:
			1:
				target.speed = 750
			2:
				target.speed = 825
			3:
				target.speed = 900


func _spawn_target_left():
	if not target_spawn_points_left.values().has(null):
		return

	var position
	var point

	while true:
		position = randi_range(0,target_spawn_points_left.size()-1)
		point = target_spawn_points_left[target_spawn_points_left.keys()[position]]
		if point == null:
			break

	var target = _create_enemy()
	target.spawn_normal()
	target.is_static = false
	target.direction = Vector2.RIGHT
	_select_type(target)

	if point != null:
		target.queue_free()
		return

	target_spawn_points_left[target_spawn_points_left.keys()[position]] = target
	spawn_zone.add_child(target)
	target.global_position = target_spawn_points_left.keys()[position].global_position

	target.killed.connect(clear_pos)

func _spawn_target_right():
	if not target_spawn_points_right.values().has(null):
		return

	var position
	var point

	while true:
		position = randi_range(0,target_spawn_points_right.size()-1)
		point = target_spawn_points_right[target_spawn_points_right.keys()[position]]
		if point == null:
			break

	var target = _create_enemy()
	target.spawn_normal()
	target.is_static = false
	target.direction = Vector2.LEFT
	_select_type(target)

	if point != null:
		target.queue_free()
		return

	target_spawn_points_right[target_spawn_points_right.keys()[position]] = target
	spawn_zone.add_child(target)
	target.global_position = target_spawn_points_right.keys()[position].global_position

	target.killed.connect(clear_pos)

func _spawn_target_up():
	if not target_spawn_points_up.values().has(null):
		return

	var position
	var point

	while true:
		position = randi_range(0,target_spawn_points_up.size()-1)
		point = target_spawn_points_up[target_spawn_points_up.keys()[position]]
		if point == null:
			break

	var target = _create_enemy()
	target.spawn_normal()
	target.is_static = false
	target.direction = Vector2.DOWN
	_select_type(target)

	if point != null:
		target.queue_free()
		return

	target_spawn_points_up[target_spawn_points_up.keys()[position]] = target
	spawn_zone.add_child(target)
	target.global_position = target_spawn_points_up.keys()[position].global_position

	target.killed.connect(clear_pos)

func clear_pos(target: Target):
	var key = target_spawn_points_left.find_key(target)
	if key != null:
		target_spawn_points_left[key] = null
		return

	var key2 = target_spawn_points_right.find_key(target)
	if key2 != null:
		target_spawn_points_right[key2] = null
		return

	var key3 = target_spawn_points_up.find_key(target)
	if key3 != null:
		target_spawn_points_up[key3] = null
		return


func _on_left_timeout():
	_spawn_target_left()


func _on_right_timeout():
	_spawn_target_right()


func _on_up_timeout():
	_spawn_target_up()
