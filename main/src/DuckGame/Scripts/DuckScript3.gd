extends GameScript

var duck_spawn_zone_1: Node2D = null
var duck_spawn_zone_2: Node2D = null

func _on_activate():
	if not Globals.game:
		await get_tree().process_frame

	duck_spawn_zone_1 = Globals.game.get_node("Background/DuckZone1")
	duck_spawn_zone_2 = Globals.game.get_node("Background/DuckZone2")

	_spawn_duck_left()
	_spawn_duck_right()

func _spawn_duck_left():
	var duck = _create_enemy()
	duck.show()
	duck.speed = 2000
	duck.set_type(3)

	duck_spawn_zone_1.add_child(duck)
	duck.global_position = Vector2(135,1235)

func _spawn_duck_right():
	var duck = _create_enemy()
	duck.show()
	duck.speed = 2000
	duck.set_type(3)

	duck_spawn_zone_2.add_child(duck)
	duck.direction = Vector2(-1,0)
	duck.global_position = Vector2(3700,1375)
