extends GameScript

@onready var left_timer: Timer = $Left
@onready var right_timer: Timer = $Right

var duck_spawn_zone_1: Node2D = null
var duck_spawn_zone_2: Node2D = null

func _on_activate():
	if not Globals.game:
		await get_tree().process_frame

	duck_spawn_zone_1 = Globals.game.get_node("Background/DuckZone1")
	duck_spawn_zone_2 = Globals.game.get_node("Background/DuckZone2")

	left_timer.start()
	right_timer.start()

func _deactivate_timers():
	left_timer.stop()
	right_timer.stop()

func _select_type(duck: Duck):
	if total_enemies % 10 == 0:
		duck.set_type(3)
		duck.speed = 1250
	elif total_enemies % 3 == 0:
		duck.set_type(2)
		duck.speed = 1000
	else:
		duck.set_type(1)
		duck.speed = 800

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
