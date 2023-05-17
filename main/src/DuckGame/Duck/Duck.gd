class_name Duck
extends Target

@onready var duck_animator: AnimationPlayer = $AnimationPlayer

var type = "_brown"

func set_type(num: int):
	match num:
		1:
			kill_score = 25
			type = "_yellow"
		2:
			kill_score = 50
			type = "_brown"
		3:
			kill_score = 100
			type = "_white"

	$MainPivot/StickPivor/Stick/DuckPivot/Duck.play("duck" + type)

func spawn_static():
	if duck_animator == null:
		await ready

	duck_animator.play("show" + type)

	await duck_animator.animation_finished
	$GoneTimer.start()

func enemy_gone():
	_is_dead = true
	duck_animator.play("hide" + type)

	await duck_animator.animation_finished
	Globals.active_script.enemy_killed()
	killed.emit(self)

func kill():
	if not duck_animator.is_playing() and not _is_dead:
		$GoneTimer.stop()
		speed = 0

		show_score_text()

		_is_dead = true
		duck_animator.play("shot" + type)

		await duck_animator.animation_finished
		killed.emit(self)

		queue_free()
