extends GameScript

@onready var spawn_timer: Timer = $SpawnTimer
@onready var spawn_zone: Node = null

func _on_activate():
	if not Globals.game:
		await get_tree().process_frame

	spawn_zone = Globals.game.get_node("Background/SpawnZone")

	spawn_timer.start()

func _select_type(target: GameTarget):
	target.set_type(5)
	target.static_duration = 0.75

func _spawn_targets():
	for position in $Positions.get_children():
		var target = _create_enemy()
		target.spawn_static()
		_select_type(target)

		target.global_position = position.global_position

func _on_spawn_timer_timeout():
	_spawn_targets()
